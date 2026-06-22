import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleMock {
  final String invoice;
  final String paymentMethod;
  final bool isPaid;
  final String time;
  final String cashier;
  final String amount;
  final String customer;
  final String date;

  SaleMock({
    required this.invoice,
    required this.paymentMethod,
    required this.isPaid,
    required this.time,
    required this.cashier,
    required this.amount,
    required this.customer,
    required this.date,
  });
}

class SaleCard extends StatelessWidget {
  final SaleMock sale;

  const SaleCard({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('saleDetails', pathParameters: {'id': sale.invoice});
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
                      sale.paymentMethod,
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: sale.isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      sale.isPaid ? 'PAID' : 'UNPAID',
                      style: TextStyle(
                        color: sale.isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                        letterSpacing: 0.3,
                      ),
                    ),
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
              Text(
                '${sale.time} • ${sale.cashier}',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
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

          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 8.h),

          // Row 3: Customer and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Customer: ${sale.customer}',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
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
}
