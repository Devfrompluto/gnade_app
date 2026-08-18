import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleCard extends StatelessWidget {
  final Sale sale;

  const SaleCard({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('saleDetails', pathParameters: {'id': sale.id});
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        children: [
          // Row 1: Invoice # and tags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sale.invoice,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _formatPaymentMethod(sale.paymentMethod),
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Builder(
                    builder: (context) {
                      final rawStatus = sale.status.toLowerCase();
                      String statusText;
                      Color bg;
                      Color fg;

                      if (rawStatus == 'paid') {
                        statusText = 'PAID';
                        bg = const Color(0xFFECFDF5);
                        fg = const Color(0xFF059669);
                      } else if (rawStatus == 'refunded') {
                        statusText = 'RETURNED';
                        bg = const Color(0xFFF3E8FF);
                        fg = const Color(0xFF9333EA);
                      } else if (rawStatus == 'partial_refund') {
                        statusText = 'P. RETURN';
                        bg = const Color(0xFFFEF3C7);
                        fg = const Color(0xFFD97706);
                      } else if (rawStatus == 'partial') {
                        statusText = 'PARTIAL';
                        bg = const Color(0xFFFFF7ED);
                        fg = const Color(0xFFD97706);
                      } else {
                        statusText = 'UNPAID';
                        bg = const Color(0xFFFEF2F2);
                        fg = const Color(0xFFDC2626);
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: fg,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Row 2: Time, Cashier and Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${sale.time} • ${sale.cashier}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                sale.amount,
                style: TextStyle(
                  color: const Color(0xFF1E3A8A), // deep blue
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (sale.status.toLowerCase() == 'partial' ||
              sale.status.toLowerCase() == 'unpaid' ||
              sale.status.toLowerCase() == 'debt') ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Paid: ',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₦ ${NumberFormat('#,##0').format(sale.amountPaid)}',
                        style: TextStyle(
                          color: const Color(0xFF059669),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 12.h,
                    color: const Color(0xFFCBD5E1),
                  ),
                  Row(
                    children: [
                      Text(
                        'Debt: ',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '₦ ${NumberFormat('#,##0').format(sale.balanceDue > 0 ? sale.balanceDue : 0)}',
                        style: TextStyle(
                          color: const Color(0xFFDC2626),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
          ],

          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 8.h),

          // Row 3: Customer and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 13.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'Customer: ${sale.customer}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    sale.date,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  String _formatPaymentMethod(String method) {
    final m = method.trim();
    final lower = m.toLowerCase();
    if (lower.startsWith('multiple')) {
      return 'MULTIPLE';
    } else if (lower == 'cash') {
      return 'CASH';
    } else if (lower == 'mobile' || lower == 'transfer') {
      return 'TRANSFER';
    } else if (lower == 'bank' || lower == 'pos') {
      return 'BANK / POS';
    } else if (lower == 'credit') {
      return 'CREDIT';
    }
    return m.toUpperCase();
  }
}
