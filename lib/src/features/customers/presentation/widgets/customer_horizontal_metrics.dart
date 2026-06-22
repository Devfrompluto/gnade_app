import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';

class CustomerHorizontalMetrics extends StatelessWidget {
  final List<CustomerMock> customers;

  const CustomerHorizontalMetrics({
    super.key,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    double totalOwed = 0;
    int debtorCount = 0;
    double totalDeposits = 0;
    int depositorCount = 0;

    for (final c in customers) {
      if (c.balance < 0) {
        totalOwed += c.balance.abs();
        debtorCount++;
      } else if (c.balance > 0) {
        totalDeposits += c.balance;
        depositorCount++;
      }
    }

    return SizedBox(
      height: 104.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // TOTAL CUSTOMERS CARD
          _buildMetricCard(
            title: 'Total',
            value: '1,248',
            subtext: '+12 this week',
            bgColor: const Color(0xFFEFF6FF), // soft blue
            textColor: const Color(0xFF1E3A8A), // dark blue
            subtextColor: const Color(0xFF10B981), // green
            icon: Icons.group_outlined,
            iconColor: const Color(0xFF3B82F6),
            isTrendUp: true,
          ),
          SizedBox(width: 12.w),

          // OWED CARD
          _buildMetricCard(
            title: 'OWED',
            value: '₦${NumberFormat('#,###').format(totalOwed == 0 ? 45000 : totalOwed)}',
            subtext: 'From ${debtorCount == 0 ? 14 : debtorCount} customers',
            bgColor: const Color(0xFFFEF2F2), // soft red
            textColor: const Color(0xFF991B1B), // dark red
            subtextColor: const Color(0xFF64748B), // grey
            icon: Icons.payment_rounded,
            iconColor: const Color(0xFFEF4444),
          ),
          SizedBox(width: 12.w),

          // DEBT (DEPOSIT) CARD
          _buildMetricCard(
            title: 'DEBT',
            value: '₦${NumberFormat('#,###').format(totalDeposits == 0 ? 5000 : totalDeposits)}',
            subtext: 'From ${depositorCount == 0 ? 2 : depositorCount} depositors',
            bgColor: const Color(0xFFECFDF5), // soft green
            textColor: const Color(0xFF047857), // dark green
            subtextColor: const Color(0xFF047857), // green
            icon: Icons.account_balance_wallet_outlined,
            iconColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtext,
    required Color bgColor,
    required Color textColor,
    required Color subtextColor,
    required IconData icon,
    required Color iconColor,
    bool isTrendUp = false,
  }) {
    return Container(
      width: 156.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 14.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              if (isTrendUp) ...[
                Icon(
                  Icons.trending_up_rounded,
                  color: subtextColor,
                  size: 11.sp,
                ),
                SizedBox(width: 2.w),
              ],
              Text(
                subtext,
                style: TextStyle(
                  color: subtextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
