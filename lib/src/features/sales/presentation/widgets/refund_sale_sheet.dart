import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../../products/presentation/providers/products_providers.dart';
import '../providers/sales_providers.dart';

class RefundSaleSheet extends ConsumerStatefulWidget {
  final Sale sale;

  const RefundSaleSheet({super.key, required this.sale});

  @override
  ConsumerState<RefundSaleSheet> createState() => _RefundSaleSheetState();
}

class _RefundSaleSheetState extends ConsumerState<RefundSaleSheet> {
  final _reasonNoteController = TextEditingController();
  
  bool _isFullRefund = true;
  String _selectedReason = 'Customer return';
  bool _isLoading = false;

  // Map item ID -> quantity to refund
  late Map<String, double> _refundQuantities;

  final List<String> _refundReasons = const [
    'Customer return',
    'Damaged goods',
    'Billing error',
    'Order cancelled',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _refundQuantities = {};
    for (final item in widget.sale.items ?? <SaleItem>[]) {
      _refundQuantities[item.id] = item.quantity;
    }
  }

  @override
  void dispose() {
    _reasonNoteController.dispose();
    super.dispose();
  }

  double get _calculatedRefundTotal {
    if (_isFullRefund) return widget.sale.totalAmount;

    double total = 0;
    for (final item in widget.sale.items ?? <SaleItem>[]) {
      final qty = _refundQuantities[item.id] ?? 0;
      total += qty * item.unitPrice;
    }
    return total;
  }

  Future<void> _processRefund() async {
    final refundItems = <Map<String, dynamic>>[];

    for (final item in widget.sale.items ?? <SaleItem>[]) {
      final qty = _isFullRefund ? item.quantity : (_refundQuantities[item.id] ?? 0.0);
      if (qty > 0) {
        refundItems.add({
          'productId': item.productId,
          'productName': item.productName,
          'quantity': qty,
          'unitPrice': item.unitPrice,
        });
      }
    }

    if (refundItems.isEmpty) {
      showGlobalToast(message: 'Please select at least 1 item quantity to refund', status: 'error');
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.refundSale(
      saleId: widget.sale.id,
      refundedItems: refundItems,
      isFullRefund: _isFullRefund,
      reason: '$_selectedReason: ${_reasonNoteController.text.trim()}',
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        showGlobalToast(message: 'Failed to process refund: ${failure.message}', status: 'error');
      },
      (refundedSale) {
        ref.invalidate(saleDetailsProvider(widget.sale.id));
        ref.invalidate(salesHistoryProvider);
        ref.invalidate(salesSummaryProvider);
        ref.invalidate(productsListProvider);

        final message = _isFullRefund
            ? 'Full sale refund completed and stock returned!'
            : 'Partial refund processed, inventory restocked!';
        showGlobalToast(message: message);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.sale.items ?? const <SaleItem>[];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 14.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Title Header
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(Icons.undo_rounded, color: const Color(0xFFDC2626), size: 22.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refund Sale',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Invoice #${widget.sale.invoiceNo}',
                          style: TextStyle(color: const Color(0xFF64748B), fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Full Refund vs Select Items Segmented Switch
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFullRefund = true;
                            for (final item in items) {
                              _refundQuantities[item.id] = item.quantity;
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _isFullRefund ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: _isFullRefund
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Refund All Items',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: _isFullRefund ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isFullRefund = false);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: !_isFullRefund ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: !_isFullRefund
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Select Items',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: !_isFullRefund ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),

              // Item Selector List when Partial Refund
              if (!_isFullRefund && items.isNotEmpty) ...[
                Text(
                  'Select Items & Quantities to Restock',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: items.map((item) {
                      final currentQty = _refundQuantities[item.id] ?? 0;

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '₦ ${NumberFormat('#,##0').format(item.unitPrice)} / unit (Max: ${item.quantity.toInt()})',
                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  onPressed: currentQty > 0
                                      ? () {
                                          setState(() {
                                            _refundQuantities[item.id] = currentQty - 1;
                                          });
                                        }
                                      : null,
                                  icon: Icon(Icons.remove_circle_outline_rounded, size: 22.sp),
                                  color: const Color(0xFFDC2626),
                                ),
                                Text(
                                  '${currentQty.toInt()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                IconButton(
                                  onPressed: currentQty < item.quantity
                                      ? () {
                                          setState(() {
                                            _refundQuantities[item.id] = currentQty + 1;
                                          });
                                        }
                                      : null,
                                  icon: Icon(Icons.add_circle_outline_rounded, size: 22.sp),
                                  color: const Color(0xFF1E40AF),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // Refund Amount Display Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Refund Amount',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B)),
                    ),
                    Text(
                      '₦ ${NumberFormat('#,##0.00').format(_calculatedRefundTotal)}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Reason for Refund Dropdown
              Text(
                'Reason for Refund',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              SizedBox(height: 6.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
                items: _refundReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _reasonNoteController,
                hint: 'Additional notes (optional)',
                maxLines: 2,
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF64748B)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Cancel', style: TextStyle(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processRefund,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Confirm Refund', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
