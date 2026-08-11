import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/supplier.dart';

class SuppliersMetricsHeader extends StatelessWidget {
  final AsyncValue<List<Supplier>> asyncList;

  const SuppliersMetricsHeader({
    super.key,
    required this.asyncList,
  });

  String _formatAmountShort(double amount) {
    if (amount >= 1000000) {
      return '₦ ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₦ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₦ ${NumberFormat('#,##0').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final list = asyncList.value ?? [];
    final count = list.length;

    double totalSupplyValue = 0;
    double totalDebtOwed = 0;

    for (final s in list) {
      totalSupplyValue += s.supplyValue;
      totalDebtOwed += s.debtAmount;
    }

    return SizedBox(
      height: 76.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildMetricCard(
            title: 'Suppliers',
            value: count.toString(),
            valueColor: const Color(0xFF1E40AF),
          ),
          SizedBox(width: 10.w),
          _buildMetricCard(
            title: 'Supply Value',
            value: _formatAmountShort(totalSupplyValue),
            valueColor: const Color(0xFF1E40AF),
          ),
          SizedBox(width: 10.w),
          _buildMetricCard(
            title: 'I Owe',
            value: _formatAmountShort(totalDebtOwed),
            valueColor: const Color(0xFFDC2626), // Red debt color
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
