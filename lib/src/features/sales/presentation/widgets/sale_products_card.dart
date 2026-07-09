import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleProductsCard extends StatelessWidget {
  final List<SaleItem> items;
  final double discount;
  final double totalAmount;

  const SaleProductsCard({
    super.key,
    required this.items,
    required this.discount,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
    final tax = totalAmount - (subtotal - discount);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRODUCTS',
              style: TextStyle(
                color: const Color(0xFFCBD5E1),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 10.sp,
              ),
            ),
            SizedBox(height: 16.h),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildProductItem(
                  item.productName,
                  '${item.quantity.toDouble()} @ ${NumberFormat('#,##0').format(item.unitPrice)}',
                  NumberFormat('#,##0').format(item.total),
                );
              },
            ),
            SizedBox(height: 16.h),
            
            CustomPaint(
              size: Size(double.infinity, 1.h),
              painter: _DashedLinePainter(),
            ),
            SizedBox(height: 16.h),
            
            if (tax > 0.01) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VAT (7.5%)',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    NumberFormat('#,##0.00').format(tax),
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
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

  Widget _buildProductItem(String title, String subtitle, String total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        Text(
          total,
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

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
