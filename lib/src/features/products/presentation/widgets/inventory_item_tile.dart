import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

enum StockStatus { outOfStock, low, inStock }

class InventoryItemTile extends StatelessWidget {
  final String name;
  final int qty;
  final String price;
  final StockStatus status;
  final VoidCallback? onTap;

  const InventoryItemTile({
    super.key,
    required this.name,
    required this.qty,
    required this.price,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    Color iconBgColor;
    Color badgeColor;
    String badgeText;

    switch (status) {
      case StockStatus.outOfStock:
        iconColor = const Color(0xFFDC2626);
        iconBgColor = const Color(0xFFFEE2E2);
        badgeColor = const Color(0xFFDC2626);
        badgeText = 'Out of Stock';
        break;
      case StockStatus.low:
        iconColor = const Color(0xFFD97706);
        iconBgColor = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFF59E0B);
        badgeText = 'Low';
        break;
      case StockStatus.inStock:
        iconColor = const Color(0xFF059669);
        iconBgColor = const Color(0xFFD1FAE5);
        badgeColor = const Color(0xFF10B981);
        badgeText = 'In Stock';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Qty: $qty • ₦$price',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
