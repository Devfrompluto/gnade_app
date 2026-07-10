import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../../auth/presentation/providers/session_provider.dart';

class SaleDetailsBottomBar extends ConsumerWidget {
  final Sale sale;

  const SaleDetailsBottomBar({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawStatus = sale.status.toLowerCase();
    final String paymentStatus = rawStatus == 'paid' 
        ? 'Paid' 
        : (rawStatus == 'partial' ? 'Partial' : 'Unpaid');
    final bool isPaid = paymentStatus == 'Paid';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? const Color(0xFFFEE2E2) : const Color(0xFF10B981), // Red if refund, Green if receive payment
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  showGlobalToast(
                    message: isPaid ? 'Refund processing is not supported yet.' : 'Payment collection is not supported yet.',
                    status: 'info',
                  );
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isPaid ? Icons.undo_outlined : Icons.payments_outlined, 
                           color: isPaid ? const Color(0xFFDC2626) : Colors.white, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        isPaid ? 'Refund the sale' : 'Receive payment',
                        style: TextStyle(
                          color: isPaid ? const Color(0xFFDC2626) : Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final businessProfile = ref.read(businessProfileProvider).value;
                  final String bName = businessProfile?.name ?? 'Kinetic Retail';
                  final String bAddress = businessProfile?.address ?? '';
                  final String bPhone = businessProfile?.phone ?? '';
                  const String bEmail = '';

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

                  final receiptData = ReceiptData(
                    businessName: bName,
                    businessAddress: bAddress,
                    businessPhone: bPhone,
                    businessEmail: bEmail,
                    invoiceNo: sale.invoiceNo,
                    dateTime: sale.createdAt,
                    customerName: sale.customerName,
                    customerType: sale.customerName == 'Retail Customer'
                        ? 'Regular Customer'
                        : 'Retail Customer',
                    items: receiptItems,
                    subtotal: calculatedSubtotal,
                    tax: calculatedTax > 0.01 ? calculatedTax : 0.0,
                    total: sale.totalAmount,
                    amountPaid: sale.amountPaid,
                    paymentMethod: displayPaymentMethod,
                    paymentStatus: paymentStatus,
                  );

                  context.push(AppRoutes.printReceipt, extra: receiptData);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.print_outlined, color: Colors.white, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Print receipt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
