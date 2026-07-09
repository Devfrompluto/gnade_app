import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductsSummaryCards extends ConsumerWidget {
  const ProductsSummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);
    
    final totalProducts = products.length;
    double totalCost = 0;
    double totalValue = 0;

    for (final p in products) {
      totalCost += p.costPrice * p.quantity;
      totalValue += p.sellPrice * p.quantity;
    }

    String formatCurrency(double val) {
      if (val >= 1000000) {
        return '₦${(val / 1000000).toStringAsFixed(1)}M';
      } else if (val >= 1000) {
        return '₦${(val / 1000).toStringAsFixed(0)}k';
      }
      return '₦${val.toStringAsFixed(0)}';
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildSummaryCard(
            title: 'Total Products',
            value: totalProducts.toString(),
            valueColor: const Color(0xFF0369A1), // Deep blue
          ),
          SizedBox(width: 12.w),
          _buildSummaryCard(
            title: 'Stock Cost',
            value: formatCurrency(totalCost),
            valueColor: const Color(0xFFF59E0B), // Amber
          ),
          SizedBox(width: 12.w),
          _buildSummaryCard(
            title: 'Stock Value',
            value: formatCurrency(totalValue),
            valueColor: const Color(0xFF10B981), // Green
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      width: 135.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 18.sp,
            ),
          ),
        ],
      ),
    );
  }
}
