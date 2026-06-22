import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';

class CustomerProfileHeader extends StatelessWidget {
  final CustomerMock customer;

  const CustomerProfileHeader({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.balance < 0;
    final hasDeposit = customer.balance > 0;

    String balanceText = '₦0';
    Color balanceColor = const Color(0xFF64748B);
    Color balanceBg = const Color(0xFFF1F5F9); // default slate-100
    if (hasDebt) {
      balanceText = '₦${NumberFormat('#,###').format(customer.balance.abs())}';
      balanceColor = const Color(0xFFDC2626); // red
      balanceBg = const Color(0xFFFEF2F2); // red-50
    } else if (hasDeposit) {
      balanceText = '₦${NumberFormat('#,###').format(customer.balance)}';
      balanceColor = const Color(0xFF059669); // green
      balanceBg = const Color(0xFFECFDF5); // emerald-50
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          // Circular Initials Avatar with Glowing Border
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: customer.initialsColor.withValues(alpha: 0.15),
                width: 2.w,
              ),
            ),
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: customer.initialsColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: customer.initialsColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  customer.initials.isEmpty ? 'C' : customer.initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 32.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Name
          Text(
            customer.name,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 20.sp,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),

          // Phone
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_in_talk_rounded, color: const Color(0xFF64748B), size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  customer.phone,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Modern Metrics Section
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24.r),
                bottomRight: Radius.circular(24.r),
              ),
              border: const Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: [
                // Purchases Metric
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // blue-50
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'PURCHASES',
                          style: TextStyle(
                            color: const Color(0xFF3B82F6), // blue-500
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${customer.purchasesCount}',
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A), // blue-900
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Balance Metric
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: balanceBg,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          customer.balance >= 0 ? 'DEPOSIT' : 'OWED',
                          style: TextStyle(
                            color: customer.balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          balanceText,
                          style: TextStyle(
                            color: balanceColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // Last Seen Metric
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB), // amber-50
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'LAST SEEN',
                          style: TextStyle(
                            color: const Color(0xFFF59E0B), // amber-500
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            customer.lastSeen,
                            style: TextStyle(
                              color: const Color(0xFF92400E), // amber-900
                              fontWeight: FontWeight.w900,
                              fontSize: 12.sp,
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
        ],
      ),
    );
  }
}
