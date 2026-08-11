import 'dart:math';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/sales_providers.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/customer_selection_card.dart';
import '../widgets/adjustments_card.dart';
import '../widgets/sale_payment_details_card.dart';
import '../widgets/sale_summary_bottom_bar.dart';
import '../widgets/complete_sale_sheet.dart';
import '../../../products/presentation/providers/products_providers.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  final List<Product> selectedItems;
  final Map<String, int> initialQuantities;

  const NewSaleScreen({
    super.key,
    required this.selectedItems,
    required this.initialQuantities,
  });

  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
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
  final TextEditingController _amountPaidController = TextEditingController(text: '');
  
  // Adjustments inputs controllers
  final TextEditingController _discountController = TextEditingController(text: '0');
  final TextEditingController _taxController = TextEditingController(text: '7.5');

  // Adjustments visibility toggles (Remove link can hide or reset them)
  bool _hasDiscount = false;
  bool _hasTax = false;

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
      final price = item.sellPrice;
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
                          final price = item.sellPrice;

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
                          if (_paymentMethod == 'Credit') {
                            _paymentMethod = 'Cash';
                          }
                          _paymentStatus = 'Paid';
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    // ─── Payment Details ─────────────────────────────────────
                    SalePaymentDetailsCard(
                      paymentMethod: _paymentMethod,
                      paymentStatus: _paymentStatus,
                      amountPaidController: _amountPaidController,
                      total: total,
                      balanceOwed: balanceOwed,
                      isCustomerSelected: _selectedCustomer != 'None' && _selectedCustomer.isNotEmpty,
                      onMethodChanged: (method) {
                        final hasCustomer = _selectedCustomer != 'None' && _selectedCustomer.isNotEmpty;
                        if (method == 'Credit' && !hasCustomer) {
                          showGlobalToast(
                            message: 'Please select a customer first to sell on credit',
                            status: 'warning',
                          );
                          return;
                        }
                        setState(() {
                          _paymentMethod = method;
                          if (method == 'Credit') {
                            _paymentStatus = 'Unpaid';
                          } else {
                            _paymentStatus = 'Paid';
                          }
                        });
                      },
                      onStatusChanged: (status) {
                        final hasCustomer = _selectedCustomer != 'None' && _selectedCustomer.isNotEmpty;
                        if ((status == 'Partial' || status == 'Unpaid') && !hasCustomer) {
                          showGlobalToast(
                            message: 'Please select a customer first to allow partial or unpaid sales',
                            status: 'warning',
                          );
                          return;
                        }
                        setState(() {
                          _paymentStatus = status;
                          if (status == 'Partial') {
                            _amountPaidController.text = '';
                          }
                        });
                      },
                      onAmountChanged: () => setState(() {}),
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
            SaleSummaryBottomBar(
              subtotal: subtotal,
              discount: discount,
              tax: tax,
              total: total,
              taxPercentage: _taxController.text,
              paymentMethod: _paymentMethod,
              paymentStatus: _paymentStatus,
              hasItems: _cartItems.isNotEmpty,
              onCompleteSale: () {
                ref.read(salesCheckoutProvider.notifier).reset();
                _showPaymentConfirmationSheet(total);
              },
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
    final initialPartialText = _amountPaidController.text.isNotEmpty
        ? _amountPaidController.text
        : (total / 2).toStringAsFixed(2);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => CompleteSaleSheet(
        total: total,
        isUnpaid: isUnpaid,
        paymentStatus: _paymentStatus,
        initialPartialText: initialPartialText,
        initialPaymentMethod: _paymentMethod,
        onConfirm: (amountReceived, selectedMethod) async {
          // ── Connectivity gate ───────────────────────
          if (!await requireConnectivity()) return;

          final businessProfile = ref.read(businessProfileProvider).value;
          final String bName = businessProfile?.name ?? 'Kinetic Retail';
          final String bAddress = businessProfile?.address ?? '';
          final String bPhone = businessProfile?.phone ?? '';
          const String bEmail = '';
          final String? bLogoUrl = businessProfile?.logoUrl;

          final receiptItems = _cartItems.map((item) {
            final qty = _quantities[item.id] ?? 1.0;
            final price = item.sellPrice;
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
          final calculatedTotal = calculatedSubtotal - calculatedDiscount + calculatedTax;
          final finalAmountPaid = isUnpaid
              ? 0.0
              : (_paymentStatus == 'Partial' ? amountReceived : calculatedTotal);

          final receiptData = ReceiptData(
            businessName: bName,
            businessAddress: bAddress,
            businessPhone: bPhone,
            businessEmail: bEmail,
            businessLogoUrl: bLogoUrl,
            invoiceNo: _invoiceNo,
            dateTime: DateTime.now(),
            customerName: _selectedCustomer == 'None' ? 'Retail Customer' : _selectedCustomer,
            customerType: _selectedCustomer == 'None' ? 'Regular Customer' : 'Retail Customer',
            items: receiptItems,
            subtotal: calculatedSubtotal,
            tax: calculatedTax,
            total: calculatedTotal,
            amountPaid: finalAmountPaid,
            paymentMethod: isUnpaid ? 'Credit' : selectedMethod,
            paymentStatus: _paymentStatus,
          );

          final saleResult = await ref.read(salesCheckoutProvider.notifier).recordSale(
            customerName: _selectedCustomer == 'None' ? 'Retail Customer' : _selectedCustomer,
            totalAmount: calculatedTotal,
            amountPaid: finalAmountPaid,
            discount: calculatedDiscount,
            paymentMethod: isUnpaid
                ? 'credit'
                : (selectedMethod.toLowerCase() == 'cash' ? 'cash' : 'transfer'),
            status: _paymentStatus == 'Unpaid' ? 'debt' : _paymentStatus.toLowerCase(),
            invoiceNo: _invoiceNo,
            items: _cartItems.map((item) {
              final qty = _quantities[item.id] ?? 1.0;
              return {
                'productId': item.id,
                'productName': item.name,
                'quantity': qty,
                'unitPrice': item.sellPrice,
                'total': item.sellPrice * qty,
              };
            }).toList(),
          );

          if (saleResult != null) {
            ref.invalidate(salesSummaryProvider);
            ref.invalidate(salesHistoryProvider(null));
            ref.invalidate(productsListProvider);

            if (context.mounted) {
              Navigator.pop(context); // pop the sheet
              context.pushReplacement(
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
            }
          } else {
            showGlobalToast(
              message: 'Failed to record sale. Please try again.',
              status: 'error',
            );
          }
        },
      ),
    );
  }
}
