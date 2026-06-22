import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleTotalsCard extends StatelessWidget {
  final String paymentStatus;
  final double total;
  final double amountPaid;

  const SaleTotalsCard({
    super.key,
    required this.paymentStatus,
    required this.total,
    required this.amountPaid,
  });

  @override
  Widget build(BuildContext context) {
    final double balanceOwed = total - amountPaid;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total amount',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  '₦ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Paid',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  '₦ ${amountPaid.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF10B981), // Green
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            if (balanceOwed > 0) ...[
              SizedBox(height: 16.h),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance Owed',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    '₦ ${balanceOwed.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: const Color(0xFFDC2626), // Red
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
