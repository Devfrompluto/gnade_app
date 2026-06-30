# SUPABASE.md — gnade_app

> This file is the single source of truth for every agent working with Supabase in this project.
> Read this fully before writing any Supabase-related code.

---

## Architecture Contract

- This app is **online-first** — all reads and writes happen against Supabase in real time.
- There is **no local database** (no Drift, no SQLite, no Hive). SharedPreferences is used only for UI preferences (saved printer, theme, last business id).
- Every Supabase call lives inside a **repository implementation** (`data/repositories/*_repository_impl.dart`) or within dedicated core services (such as `AuthService` in `lib/src/services/`) that are consumed directly by the repositories.
- **No Supabase calls from:** providers, screens, or widgets directly. Always go through the repository level.
- The Supabase client is accessed via `Supabase.instance.client` — never instantiate a new client.

```
Screen / Widget
    └── Riverpod Provider
            └── Repository (abstract)
                    └── RepositoryImpl (or base service consumed by RepositoryImpl)
                            └── Supabase.instance.client
```

---

## Client Initialization

The client is initialized once in `main.dart` using `.env` values:

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

Never hardcode the URL or anon key anywhere in source code. Never commit `.env`.

---

## Authentication

- Auth is handled entirely by Supabase Auth — do not implement a custom session system.
- After login, the SDK persists the session automatically. Do not manually cache tokens.
- Always get the current user via:

```dart
final user = Supabase.instance.client.auth.currentUser;
final session = Supabase.instance.client.auth.currentSession;
```

- Listen to auth state changes in `session_provider.dart` — do not poll.
- On logout always call:

```dart
await Supabase.instance.client.auth.signOut();
```

- The current user's `business_id` is fetched from the `users` table after login and stored in a Riverpod provider for use throughout the app. Never hardcode a business_id.

---

## Database Tables & Ownership Rules

Every table that holds business data has a `business_id` column. Every query **must** filter by `business_id`. RLS enforces this server-side but always filter client-side too for clarity and performance.

| Table                     | Primary key       | business_id         | Key columns                                                                            |
| ------------------------- | ----------------- | ------------------- | -------------------------------------------------------------------------------------- |
| `businesses`              | `id`              | — (is the business) | name, currency, logo_url, address, phone                                               |
| `users`                   | `id` (= auth.uid) | `business_id`       | full_name, phone, role                                                                 |
| `products`                | `id`              | `business_id`       | name, sku, category, cost_price, sell_price, quantity, low_stock_at, unit, expiry_date |
| `sales`                   | `id`              | `business_id`       | customer_name, total_amount, amount_paid, discount, payment_method, status, invoice_no |
| `sale_items`              | `id`              | — (via sale_id)     | sale_id, product_id, product_name, quantity, unit_price, total                         |
| `expenses`                | `id`              | `business_id`       | title, category, amount, date, created_by                                              |
| `customers`               | `id`              | `business_id`       | name, phone, email, address, notes, total_owed, deposit_amount                         |
| `suppliers`               | `id`              | `business_id`       | name, phone, supply_value, debt_amount                                                 |
| `supplier_purchases`      | `id`              | `business_id`       | supplier_id, total_amount, balance_due, status, date, subtotal, expenses, staff        |
| `supplier_purchase_items` | `id`              | — (via purchase_id) | purchase_id, product_name, quantity, unit_price, total                                 |
| `device_tokens`           | `id`              | — (via user_id)     | user_id, token, platform                                                               |
| `notification_logs`       | `id`              | `business_id`       | event, title, body, read                                                               |

---

## Row Level Security (RLS)

**RLS is enabled on every table. Never disable it. Never bypass it.**

### Rule pattern (apply to every table):

```sql
-- Users can only access rows that belong to their business
CREATE POLICY "business_isolation" ON <table>
  USING (
    business_id = (
      SELECT business_id FROM users WHERE id = auth.uid()
    )
  );

-- Users can only access their own device tokens
CREATE POLICY "own_tokens" ON device_tokens
  USING (user_id = auth.uid());
```

### Full RLS setup — run in order in the Supabase SQL editor:

```sql
-- Enable RLS on every table
ALTER TABLE businesses             ENABLE ROW LEVEL SECURITY;
ALTER TABLE users                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE products               ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items             ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses               ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers              ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers              ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_purchases     ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplier_purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens          ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_logs      ENABLE ROW LEVEL SECURITY;

-- businesses: owner can read/write their own business
CREATE POLICY "business_isolation" ON businesses
  USING (id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- users: can only see users in the same business
CREATE POLICY "business_isolation" ON users
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- products
CREATE POLICY "business_isolation" ON products
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- sales
CREATE POLICY "business_isolation" ON sales
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- sale_items: access via parent sale's business
CREATE POLICY "business_isolation" ON sale_items
  USING (
    sale_id IN (
      SELECT id FROM sales
      WHERE business_id = (SELECT business_id FROM users WHERE id = auth.uid())
    )
  );

-- expenses
CREATE POLICY "business_isolation" ON expenses
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- customers
CREATE POLICY "business_isolation" ON customers
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- suppliers
CREATE POLICY "business_isolation" ON suppliers
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- supplier_purchases
CREATE POLICY "business_isolation" ON supplier_purchases
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));

-- supplier_purchase_items: access via parent purchase's business
CREATE POLICY "business_isolation" ON supplier_purchase_items
  USING (
    purchase_id IN (
      SELECT id FROM supplier_purchases
      WHERE business_id = (SELECT business_id FROM users WHERE id = auth.uid())
    )
  );

-- device_tokens: users only see their own tokens
CREATE POLICY "own_tokens" ON device_tokens
  USING (user_id = auth.uid());

-- notification_logs
CREATE POLICY "business_isolation" ON notification_logs
  USING (business_id = (SELECT business_id FROM users WHERE id = auth.uid()));
```

### What RLS means for client code:

- You do **not** need to manually filter by `auth.uid()` in every query — RLS handles isolation.
- You **still** must filter by `business_id` in client queries for performance (index hit).
- Never use the **service role key** in Flutter. It bypasses RLS and must stay server-side only (Edge Functions).

---

## Security Rules — Non-Negotiable

### 1. Never string-interpolate values into queries

```dart
// ❌ NEVER — SQL injection risk
client.rpc('get_sales', params: {'filter': "status = '$status'"});

// ✅ ALWAYS — use the query builder or named params
client.from('sales').select().eq('status', status);
```

### 2. Always use the Supabase query builder for parameterized safety

```dart
// ✅ Safe — query builder escapes values automatically
client
  .from('products')
  .select()
  .eq('business_id', businessId)
  .eq('category', category)
  .order('name');
```

### 3. Never expose the service role key in Flutter

The service role key bypasses RLS entirely. It belongs only in:

- Supabase Edge Functions (server-side)
- `pg_cron` SQL scheduled jobs
- Never in `.env` files loaded by Flutter

### 4. Validate before insert

Always validate inputs in the domain layer before calling the repository:

```dart
// In domain or provider — before calling repo
if (sale.totalAmount <= 0) throw const InvalidSaleException();
if (product.sellPrice < product.costPrice) throw const PricingException();
```

### 5. Sanitize text inputs

Strip leading/trailing whitespace on all user text before saving:

```dart
final cleanName = customerName.trim();
final cleanTitle = expenseTitle.trim();
```

### 6. Scope every query to the current business

```dart
// ✅ Always include business_id filter
client
  .from('sales')
  .select('*, sale_items(*)')
  .eq('business_id', businessId)   // ← always
  .order('created_at', ascending: false);
```

---

## Query Conventions

### Selecting related data (joins)

Use Supabase's nested select syntax — never make multiple round trips for related data:

```dart
// ✅ Fetch sale with its items in one query
client
  .from('sales')
  .select('*, sale_items(*)')
  .eq('id', saleId)
  .single();

// ✅ Fetch supplier purchase with its items
client
  .from('supplier_purchases')
  .select('*, supplier_purchase_items(*), suppliers(name, phone)')
  .eq('id', purchaseId)
  .single();
```

### Pagination — always paginate list queries

Never fetch unbounded lists. Use `.range()` for pagination:

```dart
// Page size: 20 records
const pageSize = 20;

client
  .from('sales')
  .select('*')
  .eq('business_id', businessId)
  .order('created_at', ascending: false)
  .range(page * pageSize, (page + 1) * pageSize - 1);
```

### Single record — use `.single()` not `[0]`

```dart
// ✅
final sale = await client
    .from('sales')
    .select()
    .eq('id', saleId)
    .single();

// ❌ Don't do this
final sale = (await client.from('sales').select().eq('id', saleId))[0];
```

### Counts — use `.count()` not full fetch

```dart
// ✅ Just the count — no data transfer
final response = await client
    .from('sales')
    .select('*', const FetchOptions(count: CountOption.exact, head: true))
    .eq('business_id', businessId);
final count = response.count;
```

---

## Write Operations

### Insert

```dart
// Single insert — returns the created row
final data = await client
    .from('products')
    .insert(product.toMap())
    .select()
    .single();

// Bulk insert — sale items
await client.from('sale_items').insert(
  items.map((i) => i.toMap()..['sale_id'] = saleId).toList(),
);
```

### Update

```dart
await client
    .from('products')
    .update({'quantity': newQty, 'updated_at': DateTime.now().toIso8601String()})
    .eq('id', productId)
    .eq('business_id', businessId);  // always scope to business
```

### Upsert

Use only for known safe scenarios (e.g. device tokens, settings):

```dart
await client.from('device_tokens').upsert(
  {'user_id': userId, 'token': token, 'platform': platform},
  onConflict: 'user_id,token',
);
```

### Delete

```dart
await client
    .from('expenses')
    .delete()
    .eq('id', expenseId)
    .eq('business_id', businessId);  // always scope
```

### Critical write — creating a sale (atomic)

A sale creation must:

1. Insert the `sales` row
2. Insert all `sale_items` rows
3. Call `decrement_stock` RPC for each item

**These must be treated as a unit.** If any step fails, log and surface the error — do not partially complete a sale silently.

```dart
Future<Sale> createSale(Sale sale, List<SaleItem> items) async {
  // 1. Create sale
  final saleData = await _client
      .from('sales')
      .insert(sale.toMap())
      .select()
      .single();
  final saleId = saleData['id'] as String;

  // 2. Insert items (snapshot product name+price at time of sale)
  await _client.from('sale_items').insert(
    items.map((i) => {...i.toMap(), 'sale_id': saleId}).toList(),
  );

  // 3. Decrement stock for each item
  for (final item in items) {
    await _client.rpc('decrement_stock', params: {
      'product_id': item.productId,
      'qty': item.quantity,
    });
  }

  return Sale.fromMap(saleData);
}
```

### Critical write — creating a supplier purchase (atomic)

A supplier purchase must:

1. Insert the `supplier_purchases` row
2. Insert all `supplier_purchase_items` rows
3. Call `increment_stock` RPC for each item received

```dart
Future<void> createSupplierPurchase(
  SupplierPurchase purchase,
  List<SupplierPurchaseItem> items,
) async {
  // 1. Create purchase record
  final purchaseData = await _client
      .from('supplier_purchases')
      .insert(purchase.toMap())
      .select()
      .single();
  final purchaseId = purchaseData['id'] as String;

  // 2. Insert purchase items
  await _client.from('supplier_purchase_items').insert(
    items.map((i) => {...i.toMap(), 'purchase_id': purchaseId}).toList(),
  );

  // 3. Increment stock for each received item
  for (final item in items) {
    await _client.rpc('increment_stock', params: {
      'product_id': item.productId,
      'qty': item.quantity,
    });
  }
}
```

---

## RPC Functions

### `decrement_stock`

```sql
CREATE OR REPLACE FUNCTION decrement_stock(product_id uuid, qty int)
RETURNS void AS $$
  UPDATE products
  SET quantity = GREATEST(quantity - qty, 0)
  WHERE id = product_id;
$$ LANGUAGE sql SECURITY DEFINER;
```

- Call only once per sale item — it is **not idempotent**.
- `GREATEST(..., 0)` prevents negative stock values.

```dart
await client.rpc('decrement_stock', params: {
  'product_id': item.productId,
  'qty': item.quantity,
});
```

### `increment_stock` (for returns / restocks / supplier purchases)

```sql
CREATE OR REPLACE FUNCTION increment_stock(product_id uuid, qty int)
RETURNS void AS $$
  UPDATE products SET quantity = quantity + qty WHERE id = product_id;
$$ LANGUAGE sql SECURITY DEFINER;
```

```dart
await client.rpc('increment_stock', params: {
  'product_id': item.productId,
  'qty': item.quantity,
});
```

### `initialize_business` (atomic business + user setup on signup)

```sql
CREATE OR REPLACE FUNCTION initialize_business(
  p_business_name text,
  p_business_category text DEFAULT NULL,
  p_user_name text,
  p_user_phone text DEFAULT NULL
)
RETURNS json AS $$
DECLARE
  v_business_id uuid;
  v_user_id uuid := auth.uid();
BEGIN
  -- Idempotency: if user row exists, return existing data
  IF EXISTS (SELECT 1 FROM users WHERE id = v_user_id) THEN
    RETURN (
      SELECT json_build_object(
        'business_id', business_id,
        'role', role
      ) FROM users WHERE id = v_user_id
    );
  END IF;

  -- Create business
  INSERT INTO businesses (name, category)
  VALUES (p_business_name, p_business_category)
  RETURNING id INTO v_business_id;

  -- Create user linked to business
  INSERT INTO users (id, business_id, full_name, phone, role)
  VALUES (v_user_id, v_business_id, p_user_name, p_user_phone, 'owner');

  RETURN json_build_object(
    'business_id', v_business_id,
    'role', 'owner'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Lock down: only authenticated users can call this
REVOKE EXECUTE ON FUNCTION initialize_business FROM anon;
GRANT EXECUTE ON FUNCTION initialize_business TO authenticated;
```

- **SECURITY DEFINER** — intentionally bypasses RLS because the newly registered user has no `business_id` yet, so no RLS policy can match.
- **Idempotent** — safe to call multiple times (returns existing data on retry).
- `auth.uid()` inside the function body prevents any user from initializing for another user.
- Called once from the client immediately after `supabase.auth.signUp()`.

```dart
final result = await client.rpc('initialize_business', params: {
  'p_business_name': businessName,
  'p_business_category': businessCategory,
  'p_user_name': userName,
  'p_user_phone': userPhone,
});
// result = { "business_id": "uuid", "role": "owner" }
```

---

## Performance — Indexes

Run all indexes in the Supabase SQL editor. These are required before going to production.

```sql
-- Sales
CREATE INDEX idx_sales_business_created
  ON sales(business_id, created_at DESC);

CREATE INDEX idx_sales_status
  ON sales(business_id, status);

-- Sale items
CREATE INDEX idx_sale_items_sale
  ON sale_items(sale_id);

-- Products
CREATE INDEX idx_products_business_qty
  ON products(business_id, quantity);

CREATE INDEX idx_products_business_expiry
  ON products(business_id, expiry_date)
  WHERE expiry_date IS NOT NULL;

-- Expenses
CREATE INDEX idx_expenses_business_date
  ON expenses(business_id, date DESC);

-- Customers
CREATE INDEX idx_customers_business
  ON customers(business_id);

CREATE INDEX idx_customers_owed
  ON customers(business_id, total_owed)
  WHERE total_owed > 0;

-- Suppliers
CREATE INDEX idx_suppliers_business
  ON suppliers(business_id);

-- Supplier purchases
CREATE INDEX idx_supplier_purchases_business
  ON supplier_purchases(business_id, date DESC);

CREATE INDEX idx_supplier_purchases_supplier
  ON supplier_purchases(supplier_id);

CREATE INDEX idx_supplier_purchases_status
  ON supplier_purchases(business_id, status);

-- Supplier purchase items
CREATE INDEX idx_supplier_purchase_items_purchase
  ON supplier_purchase_items(purchase_id);

-- Notification logs
CREATE INDEX idx_notification_logs_business
  ON notification_logs(business_id, created_at DESC);

CREATE INDEX idx_notification_logs_unread
  ON notification_logs(business_id, read)
  WHERE read = false;

-- Device tokens
CREATE INDEX idx_device_tokens_user
  ON device_tokens(user_id);
```

### Additional query performance rules

#### Select only columns you need

```dart
// ❌ Fetches all columns including heavy ones
client.from('products').select();

// ✅ Only what the screen needs
client.from('products').select('id, name, sell_price, quantity, low_stock_at');
```

#### Do not fetch in a loop

```dart
// ❌ N+1 problem — one query per item
for (final saleId in saleIds) {
  final items = await client.from('sale_items').select().eq('sale_id', saleId);
}

// ✅ One query with a filter
final items = await client
    .from('sale_items')
    .select()
    .inFilter('sale_id', saleIds);
```

#### Cache the business profile

After login, load the `business` and `user` records once and store in Riverpod providers. Do not re-fetch them on every screen.

---

## Real-Time Subscriptions

Use Supabase real-time for live data only where it adds clear UX value:

| Use case                           | Subscribe to                                |
| ---------------------------------- | ------------------------------------------- |
| Dashboard sales total updates live | `sales` INSERT on `business_id`             |
| Low stock alert updates live       | `products` UPDATE on `business_id`          |
| Notification bell count            | `notification_logs` INSERT on `business_id` |

### Subscription pattern

```dart
final channel = Supabase.instance.client
    .channel('sales:$businessId')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'sales',
      filter: PostgresChangeFilter(
        type: FilterType.eq,
        column: 'business_id',
        value: businessId,
      ),
      callback: (payload) {
        ref.invalidate(salesProvider(businessId));
      },
    )
    .subscribe();

// Always unsubscribe when done
@override
void dispose() {
  Supabase.instance.client.removeChannel(channel);
  super.dispose();
}
```

**Real-time rules:**

- Always unsubscribe in `dispose()` — memory leak if not.
- Do not subscribe to the same channel twice.
- Do not use real-time for data that only needs to refresh on screen load — use `ref.invalidate` on pull-to-refresh instead.

---

## Error Handling

Every repository method must return `FutureEither<T>` using `runTask()`. Never let a raw `PostgrestException` or `AuthException` bubble up to the UI.

```dart
// ✅ Correct pattern
Future<FutureEither<List<Sale>>> getSales(String businessId) =>
    runTask(() async {
      final data = await _client
          .from('sales')
          .select('*, sale_items(*)')
          .eq('business_id', businessId)
          .order('created_at', ascending: false)
          .range(0, 19);
      return data.map(Sale.fromMap).toList();
    });

// Map known Supabase errors to domain failures in utils/error_handler.dart:
Failure mapSupabaseError(Object e) {
  if (e is PostgrestException) {
    return switch (e.code) {
      '23505' => const Failure('This record already exists.'),
      '23503' => const Failure('Related record not found.'),
      '42501' => const Failure('You do not have permission to do this.'),
      'PGRST116' => const Failure('Record not found.'),
      _ => Failure('Database error: ${e.message}'),
    };
  }
  if (e is AuthException) {
    return Failure('Authentication error: ${e.message}');
  }
  return Failure('Unexpected error: $e');
}
```

### Common Supabase error codes to handle

| Code           | Meaning                     | User message                  |
| -------------- | --------------------------- | ----------------------------- |
| `23505`        | Unique constraint violation | "This already exists"         |
| `23503`        | Foreign key violation       | "Related item not found"      |
| `42501`        | RLS policy violation        | "Access denied"               |
| `PGRST116`     | Row not found (`.single()`) | "Record not found"            |
| `AuthApiError` | Invalid credentials         | "Email or password incorrect" |

---

## Edge Functions

Edge Functions are Deno/TypeScript functions deployed to Supabase. They run server-side and are the only place the service role key is used.

### Deployed functions

| Function            | Trigger                  | What it does                             |
| ------------------- | ------------------------ | ---------------------------------------- |
| `send-notification` | DB trigger / manual call | Sends FCM push via Google Auth v1        |
| `daily-summary`     | pg_cron 20:00 daily      | Aggregates today's sales, pushes summary |
| `debt-reminder`     | pg_cron Monday 09:00     | Finds unpaid sales, pushes reminder      |

### Rules for Edge Functions

- Always use `SUPABASE_SERVICE_ROLE_KEY` from `Deno.env` — never hardcode.
- Always validate the request body before processing.
- Always return a proper HTTP response (never throw unhandled).
- Keep functions focused — one function, one job.
- Deploy via CLI: `supabase functions deploy <function-name>`

### Calling an Edge Function from Flutter

```dart
final response = await Supabase.instance.client.functions.invoke(
  'send-notification',
  body: {
    'business_id': businessId,
    'event': 'manual_test',
    'title': 'Test',
    'body': 'Test notification',
  },
);
```

---

## Database Triggers

These run automatically on the Supabase database — do not re-implement in Flutter:

| Trigger          | Table      | Fires on        | Calls                             |
| ---------------- | ---------- | --------------- | --------------------------------- |
| `on_new_sale`    | `sales`    | INSERT          | `send-notification` Edge Function |
| `on_low_stock`   | `products` | UPDATE quantity | `send-notification` Edge Function |
| `on_new_expense` | `expenses` | INSERT          | `send-notification` Edge Function |

**Do not manually call notification logic in Flutter after a sale or expense** — the DB trigger handles it automatically.

---

## Internet Connectivity

This app requires an active internet connection for all operations. Handle the offline case gracefully:

```dart
final isConnected = await InternetConnectionService.instance.isConnected;
if (!isConnected) {
  showGlobalToast(
    'No internet connection. Please check your connection and try again.',
    type: SnackBarType.error,
  );
  return;
}
```

- Use the existing `InternetConnectionService` from `lib/src/services/`.
- Show a persistent banner (not just a toast) if the user loses connection mid-session.
- Never silently fail a write — always surface connectivity errors to the user.
- Do not queue or retry writes automatically — inform the user and let them retry.

---

## Data Snapshot Rule (Sales)

When a sale is recorded, product details (name, price) **must be snapshotted** into `sale_items`. Never store only the `product_id` without the snapshot fields:

```dart
// ✅ Snapshot at time of sale — history stays accurate even if product is edited later
SaleItem(
  productId: product.id,
  productName: product.name,      // snapshot
  unitPrice: product.sellPrice,   // snapshot
  quantity: qty,
  total: product.sellPrice * qty,
);
```

This ensures sales history is never corrupted by future product price or name edits.

The same rule applies to `supplier_purchase_items` — always snapshot `product_name`, `unit_price`, and `total` at time of purchase.

---

## Naming Conventions

| Thing          | Convention              | Example                                |
| -------------- | ----------------------- | -------------------------------------- |
| Table names    | `snake_case`, plural    | `sale_items`, `supplier_purchases`     |
| Column names   | `snake_case`            | `business_id`, `created_at`            |
| RPC functions  | `snake_case`, verb_noun | `decrement_stock`, `increment_stock`   |
| Edge Functions | `kebab-case`            | `send-notification`, `daily-summary`   |
| Policies       | Descriptive string      | `'business_isolation'`, `'own_tokens'` |

---

## Hard Limits

- **Never** use the service role key in Flutter code.
- **Never** disable RLS on any table.
- **Never** write raw SQL strings with user input — always use the query builder.
- **Never** call Supabase from a widget or screen directly.
- **Never** call `decrement_stock` more than once per sale item.
- **Never** call `increment_stock` more than once per supplier purchase item.
- **Never** store plain-text passwords — Supabase Auth handles this.
- **Never** fetch unbounded lists — always use `.range()` pagination.
- **Never** ignore a `PostgrestException` — always log and surface it.
- **Never** store the service role key in `.env` files loaded by Flutter.
- **Always** filter by `business_id` in every business-data query.
- **Always** snapshot product name and price into `sale_items` at time of sale.
- **Always** snapshot product name and price into `supplier_purchase_items` at time of purchase.
- **Always** unsubscribe from real-time channels in `dispose()`.
- **Always** check internet connectivity before write operations.
