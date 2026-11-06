import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductSalesSummaryCard extends ConsumerWidget {
  final Product product;
  final String unit;

  const ProductSalesSummaryCard({
    super.key,
    required this.product,
    required this.unit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(productSalesMetricsProvider(product));
    final metrics = metricsAsync.value ?? const ProductSalesMetrics(unitsSold: 0, revenue: 0, salesCount: 0);

    final currencyFormatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦ ', decimalDigits: 0);

    final formattedUnits = metrics.unitsSold % 1 == 0
        ? metrics.unitsSold.toInt().toString()
        : metrics.unitsSold.toStringAsFixed(1);

    final unitsText = '$formattedUnits $unit';
    final revenueText = currencyFormatter.format(metrics.revenue);
    final salesText = metrics.salesCount.toString();

    final lastSoldText = metrics.lastSoldAt != null
        ? 'Last sold ${DateFormat('dd MMM yyyy • HH:mm').format(metrics.lastSoldAt!)}'
        : 'Last sold --';

    return Skeletonizer(
      enabled: metricsAsync.isLoading,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales — last 30 days',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSalesMetric('Units sold', unitsText, isBold: true),
                _buildSalesMetric('Revenue', revenueText, isGreen: true),
                _buildSalesMetric('Sales', salesText),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1, color: Colors.grey.shade200),
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.access_time_rounded, color: const Color(0xFF64748B), size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  lastSoldText,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesMetric(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: isGreen ? const Color(0xFF0D9488) : const Color(0xFF0F172A),
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
