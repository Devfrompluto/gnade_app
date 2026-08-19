import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../printing/presentation/providers/printer_providers.dart';
import 'accept_payment_sheet.dart';
import 'refund_sale_sheet.dart';

class SaleDetailsBottomBar extends ConsumerWidget {
  final Sale sale;

  const SaleDetailsBottomBar({super.key, required this.sale});

  void _showAcceptPaymentModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => AcceptPaymentSheet(sale: sale),
    );
  }

  void _showRefundModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => RefundSaleSheet(sale: sale),
    );
  }

  ReceiptData _buildReceiptData(WidgetRef ref, String paymentStatus) {
    final businessProfile = ref.read(businessProfileProvider).value;
    final String bName = businessProfile?.name ?? 'Kinetic Retail';
    final String bAddress = businessProfile?.address ?? '';
    final String bPhone = businessProfile?.phone ?? '';

    final receiptItems = (sale.items ?? <SaleItem>[]).map((item) {
      return ReceiptItem(
        name: item.productName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total,
      );
    }).toList();

    final calculatedSubtotal = receiptItems.fold<double>(0, (sum, item) => sum + item.total);
    final calculatedTax = sale.totalAmount - (calculatedSubtotal - sale.discount);

    String displayPaymentMethod = sale.paymentMethod;
    if (displayPaymentMethod.toLowerCase() == 'cash') {
      displayPaymentMethod = 'Cash';
    } else if (displayPaymentMethod.toLowerCase() == 'bank' || displayPaymentMethod.toLowerCase() == 'transfer') {
      displayPaymentMethod = 'Bank Transfer';
    } else if (displayPaymentMethod.toLowerCase() == 'mobile') {
      displayPaymentMethod = 'Mobile Payment';
    } else if (displayPaymentMethod.toLowerCase() == 'credit') {
      displayPaymentMethod = 'Credit / Debt';
    }

    return ReceiptData(
      businessName: bName,
      businessAddress: bAddress,
      businessPhone: bPhone,
      businessEmail: '',
      invoiceNo: sale.invoiceNo,
      dateTime: sale.createdAt,
      customerName: sale.customerName,
      customerType: sale.customerName == 'Retail Customer' ? 'Regular Customer' : 'Retail Customer',
      items: receiptItems,
      subtotal: calculatedSubtotal,
      tax: calculatedTax > 0.01 ? calculatedTax : 0.0,
      total: sale.totalAmount,
      amountPaid: sale.amountPaid,
      paymentMethod: displayPaymentMethod,
      paymentStatus: paymentStatus,
    );
  }

  void _printReceipt(BuildContext context, WidgetRef ref, String paymentStatus) {
    if (!checkAndPromptPrinterSetup(context, ref)) return;
    final receiptData = _buildReceiptData(ref, paymentStatus);
    context.push(AppRoutes.printReceipt, extra: receiptData);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    final bool canRefundOrAccept = user?.isAdminOrOwner ?? true;

    final rawStatus = sale.status.toLowerCase();
    final bool isPaid = rawStatus == 'paid';
    final bool isRefunded = rawStatus == 'refunded';
    final bool isPartialOrDebt = rawStatus == 'partial' || rawStatus == 'debt' || rawStatus == 'unpaid';

    final String paymentStatus = isPaid
        ? 'Paid'
        : (isRefunded ? 'Refunded' : 'Partial');

    // If staff user, only show Print button
    if (!canRefundOrAccept) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: () => _printReceipt(context, ref, paymentStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(Icons.print_outlined, size: 18.sp),
            label: Text(
              'Print Receipt',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: isPartialOrDebt
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Full-Width Primary Blue Button: Accept Payment
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAcceptPaymentModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E40AF), // Royal Blue app theme
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(Icons.payments_outlined, size: 20.sp),
                    label: Text(
                      'Accept Payment',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Bottom Row: Refund (Amber Outline) & Print (Blue Filled)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: OutlinedButton.icon(
                          onPressed: () => _showRefundModal(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          icon: Icon(Icons.undo_rounded, color: const Color(0xFFD97706), size: 16.sp),
                          label: Text(
                            'Refund',
                            style: TextStyle(
                              color: const Color(0xFFD97706),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 44.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _printReceipt(context, ref, paymentStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          icon: Icon(Icons.print_outlined, size: 16.sp),
                          label: Text(
                            'Print',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                if (!isRefunded) ...[
                  Expanded(
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRefundModal(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: Icon(Icons.undo_rounded, color: const Color(0xFFDC2626), size: 16.sp),
                        label: Text(
                          'Refund sale',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: SizedBox(
                    height: 46.h,
                    child: ElevatedButton.icon(
                      onPressed: () => _printReceipt(context, ref, paymentStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: Icon(Icons.print_outlined, size: 16.sp),
                      label: Text(
                        'Print receipt',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
