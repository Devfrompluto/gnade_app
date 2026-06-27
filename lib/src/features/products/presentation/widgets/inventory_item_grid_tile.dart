import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'inventory_item_tile.dart'; // to reuse StockStatus

class InventoryItemGridTile extends StatelessWidget {
  final String name;
  final int qty;
  final String price;
  final StockStatus status;
  final VoidCallback? onTap;

  const InventoryItemGridTile({
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
        badgeText = 'Out';
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Initial Avatar
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle, // Rounded circle looks premium for grid
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          
          // Name and Details
          Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Qty: $qty',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
              Text(
                '₦$price',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8.sp,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
