import 'dart:math';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/customers/domain/entities/customer.dart';
import '../widgets/product_item_tile.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/payment_status_selector.dart';
import '../widgets/customer_selection_card.dart';
import '../widgets/adjustments_card.dart';

class NewSaleScreen extends StatefulWidget {
  final List<ProductItemMock> selectedItems;
  final Map<String, int> initialQuantities;

  const NewSaleScreen({
    super.key,
    required this.selectedItems,
    required this.initialQuantities,
  });

  @override
  State<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends State<NewSaleScreen> {
  // Local cart items list
  late List<ProductItemMock> _cartItems;
  // Local cart item quantities
  late Map<String, double> _quantities;
  
  // Random invoice ID generated on start
  late String _invoiceNo;

  // Selected customer name
  String _selectedCustomer = 'None'; // 'None', 'Christ', 'Aunty Grace'
  
  // Payment option states
  String _paymentMethod = 'Cash'; // Cash, Mobile, Bank, Credit
  String _paymentStatus = 'Paid'; // Paid, Unpaid, Partial
  
  // Amount paid controller (used for Partial payment status)
  final TextEditingController _amountPaidController = TextEditingController(text: '50000');
  
  // Adjustments inputs controllers
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _taxController = TextEditingController(text: '7.5');

  // Adjustments visibility toggles (Remove link can hide or reset them)
  bool _hasDiscount = false;
  bool _hasTax = false;

  // Price map matching mockup exactly
  final Map<String, double> _productPrices = {
    'p1': 45000, // Premium Rice 50kg
    'p2': 8500,  // Vegetable Oil 5L
    'p3': 1500,  // Burst Berry drink
    'p4': 2000,  // Star radler bottle
    'p5': 2200,  // Tiger bottle
  };

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.selectedItems);
    _quantities = widget.initialQuantities.map((key, value) => MapEntry(key, value.toDouble()));

    // Generate random invoice: BZ + 8 digits
    final random = Random();
    final digits = List.generate(8, (_) => random.nextInt(10).toString()).join();
    _invoiceNo = 'BZ$digits';

    // Make sure we have a quantity of at least 1 for each cart item
    for (final item in _cartItems) {
      if (!_quantities.containsKey(item.id) || _quantities[item.id]! <= 0) {
        _quantities[item.id] = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  // Calculate Subtotal
  double _calculateSubtotal() {
    double sub = 0;
    for (final item in _cartItems) {
      final qty = _quantities[item.id] ?? 0.0;
      final price = _productPrices[item.id] ?? 0.0;
      sub += price * qty;
    }
    return sub;
  }

  // Calculate Discount
  double _getDiscountValue() {
    if (!_hasDiscount) return 0;
    return double.tryParse(_discountController.text) ?? 0;
  }

  // Calculate Tax (7.5% by default)
  double _getTaxValue(double subtotal) {
    if (!_hasTax) return 0;
    final taxPercent = double.tryParse(_taxController.text) ?? 0;
    return (subtotal - _getDiscountValue()) * (taxPercent / 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Recalculate totals on rebuild
    final subtotal = _calculateSubtotal();
    final discount = _getDiscountValue();
    final tax = _getTaxValue(subtotal);
    final total = subtotal - discount + tax;

    // Partial calculations
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    final balanceOwed = total - amountPaid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Sale',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 16.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding.w,
                  vertical: 14.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Items Header Row ────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(), // Returns to SelectItemScreen
                          child: Text(
                            '+ Add More',
                            style: TextStyle(
                              color: const Color(0xFF0A4FCD),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // ─── Selected Items List ─────────────────────────────────
                    if (_cartItems.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        alignment: Alignment.center,
                        child: Text(
                          'No items selected',
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13.sp,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _cartItems.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final qty = _quantities[item.id] ?? 1.0;
                          final price = _productPrices[item.id] ?? 0;

                          return CartItemTile(
                            item: item,
                            quantity: qty,
                            unitPrice: price,
                            onQuantityChanged: (newQty) {
                              setState(() {
                                _quantities[item.id] = newQty;
                              });
                            },
                            onRemove: () {
                              setState(() {
                                _cartItems.removeAt(index);
                                _quantities.remove(item.id);
                              });
                            },
                          );
                        },
                      ),
                    SizedBox(height: 20.h),

                    // ─── Customer Selection Card ─────────────────────────────
                    Text(
                      'Customer (Optional)',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomerSelectionCard(
                      selectedCustomer: _selectedCustomer,
                      onTap: _selectCustomer,
                      onRemove: () {
                        setState(() {
                          _selectedCustomer = 'None';
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    // ─── Payment Details ─────────────────────────────────────
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Payment Method Title
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          PaymentMethodSelector(
                            selectedMethod: _paymentMethod,
                            onMethodChanged: (method) {
                              setState(() {
                                _paymentMethod = method;
                              });
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Payment Status Title
                          Text(
                            'Payment Status',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          PaymentStatusSelector(
                            selectedStatus: _paymentStatus,
                            onStatusChanged: (status) {
                              setState(() {
                                _paymentStatus = status;
                                // Default amount paid for Partial
                                if (status == 'Partial') {
                                  _amountPaidController.text = '50000';
                                }
                              });
                            },
                          ),
                          SizedBox(height: 16.h),

                          // ─── Conditional Partial payment inputs ─────────────
                          if (_paymentStatus == 'Partial') ...[
                            Text(
                              'Amount Paid',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC), // soft input bg
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: TextField(
                                controller: _amountPaidController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                                    child: Text(
                                      '₦',
                                      style: TextStyle(
                                        color: const Color(0xFF1E293B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Balance Owed Banner (Red)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Balance Owed',
                                    style: TextStyle(
                                      color: const Color(0xFFDC2626),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                  Text(
                                    '₦ ${balanceOwed > 0 ? balanceOwed.toStringAsFixed(2) : "0.00"}',
                                    style: TextStyle(
                                      color: const Color(0xFFDC2626),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_paymentStatus == 'Unpaid') ...[
                            // Unpaid Owed Banner (Red)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: const Color(0xFFDC2626),
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Balance Owed (Unpaid)',
                                          style: TextStyle(
                                            color: const Color(0xFFDC2626),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                        Text(
                                          '₦ ${total.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: const Color(0xFFDC2626),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // ─── Adjustments Card (Shown in image 2) ──────────────────
                    AdjustmentsCard(
                      discountController: _discountController,
                      taxController: _taxController,
                      hasDiscount: _hasDiscount,
                      hasTax: _hasTax,
                      onDiscountRemoved: () {
                        setState(() {
                          _discountController.text = '0';
                          _hasDiscount = false;
                        });
                      },
                      onTaxRemoved: () {
                        setState(() {
                          _taxController.text = '0';
                          _hasTax = false;
                        });
                      },
                      onDiscountAdded: () {
                        setState(() {
                          _hasDiscount = true;
                        });
                      },
                      onTaxAdded: () {
                        setState(() {
                          _hasTax = true;
                        });
                      },
                      onChanged: () => setState(() {}),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // ─── Summary section & Complete Sale button ──────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtotal row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                        Text(
                          '₦ ${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Discount row (if discount > 0)
                    if (discount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount',
                            style: TextStyle(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            '- ₦ ${discount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                    ],

                    // Tax row (if tax > 0)
                    if (tax > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax (${_taxController.text}%)',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            '₦ ${tax.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: const Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                    ],

                    const Divider(color: Color(0xFFE2E8F0), height: 1),
                    SizedBox(height: 8.h),

                    // Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          '₦ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    // Payment status indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Status',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: _paymentStatus == 'Paid'
                                ? const Color(0xFFECFDF5)
                                : _paymentStatus == 'Partial'
                                    ? const Color(0xFFFFF7ED)
                                    : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _paymentStatus,
                            style: TextStyle(
                              color: _paymentStatus == 'Paid'
                                  ? const Color(0xFF059669)
                                  : _paymentStatus == 'Partial'
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFFDC2626),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Complete Sale Button
                    SizedBox(
                      width: double.infinity,
                      height: 44.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F9F68), // Green complete button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _cartItems.isEmpty
                            ? null
                            : () {
                                _showPaymentConfirmationSheet(total);
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Complete Sale',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Navigate to Select Customer screen and bind result
  Future<void> _selectCustomer() async {
    final customer = await context.push<CustomerMock>(AppRoutes.selectCustomer);
    if (customer != null) {
      setState(() {
        _selectedCustomer = customer.name;
      });
    }
  }

  // Dynamic bottom sheet for custom payment and quick amount calculations
  void _showPaymentConfirmationSheet(double total) {
    final isUnpaid = _paymentStatus == 'Unpaid';
    final TextEditingController amountController = TextEditingController(
      text: _paymentStatus == 'Partial' ? '50000.00' : (isUnpaid ? '0.00' : total.toStringAsFixed(2)),
    );
    String selectedMethod = isUnpaid ? 'Credit' : 'Cash'; // Cash, Bank, Card
    double amountReceived = _paymentStatus == 'Partial' ? 50000.0 : (isUnpaid ? 0.0 : total);

    // Generate quick pills based on total
    final ceil1k = (total / 1000).ceil() * 1000.0;
    final ceil5k = (total / 5000).ceil() * 5000.0;
    final ceil10k = (total / 10000).ceil() * 10000.0;

    final List<double> quickAmounts = [];
    if (ceil1k > total) quickAmounts.add(ceil1k);
    if (ceil5k > ceil1k) quickAmounts.add(ceil5k);
    if (ceil10k > ceil5k) quickAmounts.add(ceil10k);

    while (quickAmounts.length < 3) {
      final lastVal = quickAmounts.isEmpty ? total : quickAmounts.last;
      quickAmounts.add(((lastVal + 1000) / 1000).ceil() * 1000.0);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, sheetSetState) {
            final changeDue = amountReceived > total ? amountReceived - total : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Header title + Close X button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complete Sale',
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 20.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Total Due section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'TOTAL DUE',
                          style: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '₦ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFF0F9F68),
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ── Unpaid Credit Warning ──────────────────────────────────
                  if (isUnpaid) ...[ 
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: const Color(0xFFDC2626), size: 18.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Unpaid / Debt Sale: The customer will receive goods on credit. An outstanding balance of ₦ ${total.toStringAsFixed(2)} will be logged.',
                              style: TextStyle(
                                color: const Color(0xFFDC2626),
                                fontSize: 11.sp,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ] else ...[ 
                    // ── Payment Method Selector ────────────────────────────
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentMethodCard(
                            title: 'Cash',
                            icon: Icons.payments_outlined,
                            isSelected: selectedMethod == 'Cash',
                            onTap: () => sheetSetState(() => selectedMethod = 'Cash'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildPaymentMethodCard(
                            title: 'Bank',
                            icon: Icons.account_balance_outlined,
                            isSelected: selectedMethod == 'Bank',
                            onTap: () => sheetSetState(() => selectedMethod = 'Bank'),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _buildPaymentMethodCard(
                            title: 'Mobile',
                            icon: Icons.phone_android_outlined,
                            isSelected: selectedMethod == 'Mobile',
                            onTap: () => sheetSetState(() => selectedMethod = 'Mobile'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // ── Amount Received Field ─────────────────────────────
                    Text(
                      'Amount Received (₦)',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        onChanged: (val) {
                          sheetSetState(() {
                            amountReceived = double.tryParse(val) ?? 0;
                          });
                        },
                        decoration: InputDecoration(
                          prefixText: '₦  ',
                          prefixStyle: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h, horizontal: 12.w),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // ── Quick Amount Pills ────────────────────────────────
                    Row(
                      children: quickAmounts
                          .take(3)
                          .map(
                            (amount) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: _buildQuickAmountPill(
                                text: '₦${(amount / 1000).toStringAsFixed(0)}k',
                                onTap: () {
                                  amountController.text = amount.toStringAsFixed(0);
                                  sheetSetState(() => amountReceived = amount);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 14.h),

                    // ── Change Due Banner ─────────────────────────────────
                    if (changeDue > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change Due',
                              style: TextStyle(
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                            Text(
                              '₦ ${changeDue.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: const Color(0xFF059669),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // ── Partial validation warning ────────────────────────
                    if (_paymentStatus == 'Partial' && amountReceived >= total)
                      Container(
                        margin: EdgeInsets.only(top: 8.h),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Amount paid cannot be equal to or greater than the total for a partial payment.',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                  ],

                  // ── Confirm Button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUnpaid
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F9F68),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Block partial if amount >= total
                        if (_paymentStatus == 'Partial' && amountReceived >= total) {
                          return;
                        }
                        // Block partial if field is empty / zero
                        if (_paymentStatus == 'Partial' && amountReceived <= 0) {
                          return;
                        }
                        Navigator.pop(context);

                        final receiptItems = _cartItems.map((item) {
                          final qty = _quantities[item.id] ?? 1.0;
                          final price = _productPrices[item.id] ?? 0.0;
                          return ReceiptItem(
                            name: item.name,
                            quantity: qty,
                            unitPrice: price,
                            total: price * qty,
                          );
                        }).toList();

                        final calculatedSubtotal = _calculateSubtotal();
                        final calculatedDiscount = _getDiscountValue();
                        final calculatedTax = _getTaxValue(calculatedSubtotal);
                        final calculatedTotal =
                            calculatedSubtotal - calculatedDiscount + calculatedTax;
                        final finalAmountPaid = isUnpaid
                            ? 0.0
                            : (_paymentStatus == 'Partial'
                                ? amountReceived
                                : calculatedTotal);

                        final receiptData = ReceiptData(
                          businessName: 'GNADE MULTICONCEPT',
                          businessAddress: '123 Market Street, Victoria Island, Lagos',
                          businessPhone: '+234 800 123 4567',
                          businessEmail: 'contact@gnademulticoncept.com',
                          invoiceNo: _invoiceNo,
                          dateTime: DateTime.now(),
                          customerName: _selectedCustomer == 'None'
                              ? 'Retail Customer'
                              : _selectedCustomer,
                          customerType: _selectedCustomer == 'None'
                              ? 'Regular Customer'
                              : 'Retail Customer',
                          items: receiptItems,
                          subtotal: calculatedSubtotal,
                          tax: calculatedTax,
                          total: calculatedTotal,
                          amountPaid: finalAmountPaid,
                          paymentMethod: isUnpaid ? 'Credit' : selectedMethod,
                          paymentStatus: _paymentStatus,
                        );

                        context.push(
                          AppRoutes.saleSuccess,
                          extra: {
                            'invoiceNo': _invoiceNo,
                            'amountPaid': finalAmountPaid,
                            'paymentMethod': isUnpaid ? 'Credit' : selectedMethod,
                            'paymentStatus': _paymentStatus,
                            'total': calculatedTotal,
                            'dateTime': DateTime.now(),
                            'receiptData': receiptData,
                          },
                        );
                      },
                      child: Text(
                        isUnpaid ? 'Confirm Debt / Unpaid Sale' : 'Confirm Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Cancel link
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildPaymentMethodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountPill({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}
