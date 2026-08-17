# INSTRUCTIONS.md — Multi-Price & Half-Unit Quantity Feature

> This file tells the agent exactly what to change, in what order, and why.
> Read every section fully before writing any code.
> Do not skip steps — each layer depends on the one before it.

---

## What This Feature Does

Products can have up to 3 price points:

- `sell_price` — existing wholesale price (always required)
- `half_unit_price` — price for 0.5 of one unit (optional, set by owner)
- `party_price` — alternative bulk/event price per full unit (optional, set by owner)

On the sale screen, quantities allow `.5` increments. When a quantity like 1.5 is entered under wholesale pricing, the app calculates:

```
1.5 units = 1 full unit × sell_price + half_unit_price
```

NOT `1.5 × sell_price` — that would be wrong.

Party price always multiplies uniformly: `quantity × party_price` (no half-unit split).

Prices can only be set or edited on the product screen by the owner. Staff cannot edit, override, or see prices as input fields on the sale screen.

---

## STEP 1 — Database Changes

Run these SQL statements in the Supabase SQL editor in this exact order.

### 1a. Add price columns to `products`

```sql
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS half_unit_price numeric DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS party_price     numeric DEFAULT NULL;
```

`null` means that price type is not available for this product. Never default to 0 — 0 would be treated as a valid price.

### 1b. Change `quantity` from `int` to `numeric`

```sql
ALTER TABLE products
  ALTER COLUMN quantity TYPE numeric USING quantity::numeric;
```

This allows quantities like 1.5, 2.5 to be stored without truncation.

### 1c. Add `price_type` to `sale_items`

```sql
ALTER TABLE sale_items
  ADD COLUMN IF NOT EXISTS price_type text
    CHECK (price_type IN ('wholesale', 'party'))
    DEFAULT 'wholesale';
```

This snapshots which price type was used at the time of sale. Required for correct receipt display and sales history.

### 1d. Update `decrement_stock` RPC to accept `numeric`

```sql
CREATE OR REPLACE FUNCTION decrement_stock(product_id uuid, qty numeric)
RETURNS void AS $$
  UPDATE products
  SET quantity = GREATEST(quantity - qty, 0)
  WHERE id = product_id;
$$ LANGUAGE sql SECURITY DEFINER;
```

Note: parameter type changed from `int` to `numeric`. This is a breaking change — update all callers.

---

## STEP 2 — Domain Entity Changes

### 2a. Update `Product` entity

File: `lib/src/features/inventory/domain/entities/product.dart`

Add these fields:

```dart
final double? halfUnitPrice;   // null = half unit not available for this product
final double? partyPrice;      // null = party price not available for this product
```

Add these computed getters:

```dart
bool get hasHalfUnit  => halfUnitPrice != null && halfUnitPrice! > 0;
bool get hasPartyPrice => partyPrice != null && partyPrice! > 0;

/// Returns available price types for this product
List<String> get availablePriceTypes {
  return [
    'wholesale',
    if (hasPartyPrice) 'party',
  ];
}
```

### 2b. Update `ProductModel` (data layer)

File: `lib/src/features/inventory/data/models/product_model.dart`

Add to `fromMap()`:

```dart
halfUnitPrice: (map['half_unit_price'] as num?)?.toDouble(),
partyPrice:    (map['party_price'] as num?)?.toDouble(),
```

Add to `toMap()`:

```dart
'half_unit_price': halfUnitPrice,
'party_price':     partyPrice,
```

### 2c. Update `SaleItem` entity

File: `lib/src/features/sales/domain/entities/sale_item.dart`

Add this field:

```dart
final String priceType;   // 'wholesale' | 'party' — defaults to 'wholesale'
```

Update `toMap()` to include:

```dart
'price_type': priceType,
```

Update `fromMap()` to include:

```dart
priceType: (map['price_type'] as String?) ?? 'wholesale',
```

---

## STEP 3 — Price Calculation Utility

Create this file. Do not put this logic in a widget or provider.

File: `lib/src/shared/helpers/price_calculator.dart`

```dart
class PriceCalculator {
  PriceCalculator._();

  /// Calculates the correct line total for a sale item.
  ///
  /// Rules:
  /// - Party price: quantity × partyPrice (uniform, no half-unit split)
  /// - Wholesale with whole quantity: quantity × wholesalePrice
  /// - Wholesale with .5 quantity: floor(qty) × wholesalePrice + halfUnitPrice
  ///
  /// Throws [ArgumentError] if:
  /// - priceType is 'party' but partyPrice is null
  /// - quantity has .5 decimal but halfUnitPrice is null
  /// - quantity has a decimal other than .5 (e.g. 1.3 is not allowed)
  static double calculateLineTotal({
    required double quantity,
    required double wholesalePrice,
    required double? halfUnitPrice,
    required double? partyPrice,
    required String priceType,
  }) {
    // Validate quantity — only whole numbers and .5 are allowed
    final decimal = quantity % 1;
    if (decimal != 0 && decimal != 0.5) {
      throw ArgumentError(
        'Quantity must be a whole number or end in .5. Got: $quantity',
      );
    }

    if (priceType == 'party') {
      if (partyPrice == null) {
        throw ArgumentError('Party price is not set for this product');
      }
      // Party price: simple multiplication, no half-unit logic
      return quantity * partyPrice;
    }

    // Wholesale price logic
    final fullUnits = quantity.floor().toDouble();
    final hasHalf   = decimal == 0.5;

    if (hasHalf && (halfUnitPrice == null || halfUnitPrice == 0)) {
      throw ArgumentError(
        'Half unit price is not set for this product. Cannot sell 0.5 units.',
      );
    }

    final fullTotal = fullUnits * wholesalePrice;
    final halfTotal = hasHalf ? halfUnitPrice! : 0.0;

    return fullTotal + halfTotal;
  }

  /// Returns the display price label for a sale item line.
  /// Used on receipts and sale history.
  static String priceLabel({
    required double quantity,
    required double wholesalePrice,
    required double? halfUnitPrice,
    required double? partyPrice,
    required String priceType,
    required String currency,
  }) {
    if (priceType == 'party') {
      return '$currency${partyPrice!.toStringAsFixed(0)}/unit (party)';
    }

    final hasHalf = (quantity % 1) == 0.5;
    if (hasHalf) {
      return '$currency${wholesalePrice.toStringAsFixed(0)} + $currency${halfUnitPrice!.toStringAsFixed(0)} half';
    }

    return '$currency${wholesalePrice.toStringAsFixed(0)}/unit';
  }
}
```

---

## STEP 4 — Product Screen Changes (Owner Only)

File: `lib/src/features/inventory/presentation/screens/add_product_screen.dart`
(and any edit product screen)

### What to add

Add two optional price input fields below the existing `sell_price` field. These fields must only be visible when the current user's role is `owner`. Use `ref.watch(activeMembershipProvider)` to check.

```dart
// Show only if owner
if (isOwner) ...[
  const SizedBox(height: 12),
  AppTextField(
    controller:   _halfUnitPriceCtr,
    label:        'Half Unit Price (optional)',
    prefixText:   '₦ ',
    keyboardType: const TextInputType.numberWithOptions(decimal: false),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    helperText:   'Price when customer buys half a unit e.g. half a crate',
    // No validator — field is optional
  ),
  const SizedBox(height: 12),
  AppTextField(
    controller:   _partyPriceCtr,
    label:        'Party Price (optional)',
    prefixText:   '₦ ',
    keyboardType: const TextInputType.numberWithOptions(decimal: false),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    helperText:   'Alternative price for party/bulk orders',
  ),
]
```

### Parsing the values before save

```dart
// In _submit() — parse optional prices
final halfUnitPrice = _halfUnitPriceCtr.text.trim().isEmpty
    ? null
    : double.tryParse(_halfUnitPriceCtr.text.trim());

final partyPrice = _partyPriceCtr.text.trim().isEmpty
    ? null
    : double.tryParse(_partyPriceCtr.text.trim());
```

Never save `0` for these fields — save `null` if empty. A price of 0 would allow free sales.

### Pre-filling on edit

When editing an existing product, pre-fill these controllers:

```dart
_halfUnitPriceCtr.text = product.halfUnitPrice?.toStringAsFixed(0) ?? '';
_partyPriceCtr.text    = product.partyPrice?.toStringAsFixed(0) ?? '';
```

---

## STEP 5 — Sale Screen Changes

File: `lib/src/features/sales/presentation/screens/new_sale_screen.dart`
and the cart item widget: `lib/src/features/sales/presentation/widgets/cart_item_widget.dart`

### 5a. Quantity stepper — allow .5 steps

The quantity stepper must:

- Start at `1.0`
- Increase/decrease in steps of `0.5`
- Never go below `0.5`
- Display as `1`, `1.5`, `2`, `2.5` (no trailing `.0` for whole numbers)
- Disable the `.5` step if `product.hasHalfUnit` is false

```dart
void _incrementQty() {
  setState(() => _quantity = _quantity + 0.5);
}

void _decrementQty() {
  if (_quantity <= 0.5) return;

  // If half unit not available, skip .5 steps going down
  if (!widget.product.hasHalfUnit && (_quantity - 0.5) % 1 != 0) {
    setState(() => _quantity = _quantity - 1.0);
    return;
  }

  setState(() => _quantity = _quantity - 0.5);
}

String get _qtyDisplay {
  return _quantity % 1 == 0
      ? _quantity.toInt().toString()       // "2"
      : _quantity.toStringAsFixed(1);      // "1.5"
}
```

### 5b. Price type selector — wholesale or party

Show this selector per cart item, not globally. Each item in the cart can independently be wholesale or party priced.

Show the selector only if `product.availablePriceTypes.length > 1` — if only wholesale exists, hide the selector entirely (no clutter for products without party price).

```dart
if (product.availablePriceTypes.length > 1)
  Row(
    children: product.availablePriceTypes.map((type) {
      final isSelected = _priceType == type;
      return GestureDetector(
        onTap: () => setState(() {
          _priceType = type;
          _recalculate();
        }),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color:        isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type == 'wholesale' ? 'Wholesale' : 'Party',
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      );
    }).toList(),
  ),
```

### 5c. Line total calculation — use PriceCalculator

Replace any existing `quantity * price` multiplication with:

```dart
void _recalculate() {
  try {
    _lineTotal = PriceCalculator.calculateLineTotal(
      quantity:      _quantity,
      wholesalePrice: widget.product.sellPrice,
      halfUnitPrice:  widget.product.halfUnitPrice,
      partyPrice:     widget.product.partyPrice,
      priceType:      _priceType,
    );
  } on ArgumentError catch (e) {
    // e.g. half unit price not set but .5 qty selected
    showGlobalToast(e.message, type: SnackBarType.error);
    // Revert quantity to last valid whole number
    setState(() => _quantity = _quantity.floor().toDouble());
    _recalculate();
  }
}
```

Call `_recalculate()` every time quantity or price type changes.

### 5d. Building the SaleItem from cart

When the sale is confirmed, build each `SaleItem` like this:

```dart
SaleItem(
  productId:   product.id,
  productName: product.name,     // snapshot
  unitPrice:   product.sellPrice, // always snapshot wholesale price
  quantity:    _quantity,
  total:       _lineTotal,        // the correctly calculated total
  priceType:   _priceType,        // 'wholesale' | 'party' — snapshot
)
```

Note: `unitPrice` always stores the wholesale price regardless of price type. The `total` is what was actually charged. The `priceType` records which pricing was used. This ensures receipts can show the right breakdown.

---

## STEP 6 — Repository Change

File: `lib/src/features/sales/data/repositories/sale_repository_impl.dart`

Update the `decrement_stock` RPC call — the `qty` param is now `numeric` not `int`:

```dart
// Before
await _client.rpc('decrement_stock', params: {
  'product_id': item.productId,
  'qty':        item.quantity.toInt(),  // ❌ truncates 1.5 to 1
});

// After
await _client.rpc('decrement_stock', params: {
  'product_id': item.productId,
  'qty':        item.quantity,          // ✅ passes 1.5 as-is
});
```

---

## STEP 7 — Receipt Display

File: `lib/src/features/printing/data/pdf_receipt_generator.dart`
and the in-app receipt preview widget.

Update the item row on receipts to show the price type clearly:

```dart
// Item row on receipt — show price type if party
final priceLabel = item.priceType == 'party'
    ? '${data.currency}${item.total.toStringAsFixed(0)} (party price)'
    : '${data.currency}${item.total.toStringAsFixed(0)}';

// Quantity display — show 1.5 not 1.50
final qtyLabel = item.quantity % 1 == 0
    ? item.quantity.toInt().toString()
    : item.quantity.toStringAsFixed(1);
```

---

## STEP 8 — Validation Rules (enforce everywhere)

These rules must be enforced at the UI layer, not just the calculation layer:

| Rule                                                             | Where to enforce                      |
| ---------------------------------------------------------------- | ------------------------------------- |
| Half unit price must be less than wholesale price                | Product form validator                |
| Party price must be less than wholesale price                    | Product form validator                |
| Quantity `.5` step only allowed if `product.hasHalfUnit`         | Quantity stepper — disable step       |
| Party option only shown if `product.hasPartyPrice`               | Price type selector — hide if null    |
| Prices are read-only on sale screen                              | No editable price fields in cart item |
| Only owner sees half unit + party price fields on product screen | Check `activeMembershipProvider`      |

---

## STEP 9 — Verification Checklist

Before marking this feature complete, verify each of these manually:

- [ ] 1 crate wholesale → `1 × sell_price` ✓
- [ ] 2 crates wholesale → `2 × sell_price` ✓
- [ ] 1.5 crates wholesale → `sell_price + half_unit_price` ✓
- [ ] 2.5 crates wholesale → `(2 × sell_price) + half_unit_price` ✓
- [ ] 1.5 crates party → `1.5 × party_price` ✓
- [ ] Product with no party price → party option not shown on sale screen ✓
- [ ] Product with no half unit price → `.5` step disabled on stepper ✓
- [ ] Stock deducted by 1.5 when 1.5 sold ✓
- [ ] Receipt shows correct total and price type ✓
- [ ] Sale history shows `price_type` correctly ✓
- [ ] Staff cannot edit any price on sale screen ✓
- [ ] Owner can clear half unit / party price (save as null, not 0) ✓
- [ ] `decrement_stock` RPC accepts numeric qty without error ✓

---

## Files Changed Summary

| File                         | Change                                                                                                                                       |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Supabase SQL                 | Add `half_unit_price`, `party_price` to products. Change `quantity` to numeric. Add `price_type` to sale_items. Update `decrement_stock` RPC |
| `product.dart`               | Add `halfUnitPrice`, `partyPrice`, `hasHalfUnit`, `hasPartyPrice`, `availablePriceTypes`                                                     |
| `product_model.dart`         | Map new columns in `fromMap` / `toMap`                                                                                                       |
| `sale_item.dart`             | Add `priceType` field                                                                                                                        |
| `sale_item_model.dart`       | Map `price_type` in `fromMap` / `toMap`                                                                                                      |
| `price_calculator.dart`      | New file — `PriceCalculator.calculateLineTotal()`                                                                                            |
| `add_product_screen.dart`    | Add half unit + party price fields (owner only)                                                                                              |
| `cart_item_widget.dart`      | Add `.5` step stepper + price type selector + `_recalculate()`                                                                               |
| `new_sale_screen.dart`       | Build `SaleItem` with `priceType` and correct `total`                                                                                        |
| `sale_repository_impl.dart`  | Pass `qty` as `double` not `int` to `decrement_stock`                                                                                        |
| `pdf_receipt_generator.dart` | Show price type on receipt item rows                                                                                                         |
| Receipt preview widget       | Show qty as `1.5` not `1.50`, show price type label                                                                                          |

---

## Hard Rules for This Feature

- **Never** multiply `quantity × sell_price` directly — always use `PriceCalculator.calculateLineTotal()`
- **Never** allow quantity decimals other than `.5`
- **Never** save `half_unit_price` or `party_price` as `0` — use `null` for "not set"
- **Never** show price type selector if only one price type is available
- **Never** let staff edit prices — the price type selector is not a price field
- **Always** snapshot `price_type` into `sale_items` at time of sale
- **Always** use `item.total` from the sale item for receipt display — never recalculate on display
