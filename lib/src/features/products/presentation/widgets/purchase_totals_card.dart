import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class PurchaseTotalsCard extends StatelessWidget {
  final SupplierPurchaseMock purchase;

  const PurchaseTotalsCard({
    super.key,
    required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Subtotal Row
          _buildRow(
            label: 'Subtotal',
            value: purchase.subtotal,
          ),
          SizedBox(height: 12.h),

          // Expenses Row
          _buildRow(
            label: 'Expenses',
            value: purchase.expenses,
          ),
          SizedBox(height: 16.h),

          // Dashed Divider
          const DashedDivider(height: 1),
          SizedBox(height: 16.h),

          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                '₦${purchase.totalAmount}',
                style: TextStyle(
                  color: const Color(0xFFF59E0B), // amber/orange color
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        Text(
          value.isEmpty || value == '0' ? '0' : '₦$value',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dashWidth;
  final double dashGap;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xFFCBD5E1),
    this.dashWidth = 4,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashGap)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
