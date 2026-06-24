import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/notification_item.dart';
import '../providers/notifications_provider.dart';

class NotificationTile extends ConsumerWidget {
  final NotificationItem item;

  const NotificationTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bgColor, iconColor, icon) = _getCategoryStyle();

    // Format timestamp
    final timeStr = _formatTimestamp(item.timestamp);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!item.isRead) {
              ref.read(notificationsListProvider.notifier).markAsRead(item.id);
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Badge
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Content Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row (Title + Timestamp + Unread Dot)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!item.isRead) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB), // Vibrant blue dot
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontSize: 13.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, IconData) _getCategoryStyle() {
    switch (item.category.toLowerCase()) {
      case 'sales':
        return (
          const Color(0xFFEFF6FF), // blue-50
          const Color(0xFF2563EB), // blue-600
          Icons.shopping_cart_outlined,
        );
      case 'stock':
        return (
          const Color(0xFFFFFBEB), // amber-50
          const Color(0xFFD97706), // amber-600
          Icons.warning_amber_rounded,
        );
      case 'expenses':
        return (
          const Color(0xFFF1F5F9), // slate-100
          const Color(0xFF64748B), // slate-500
          Icons.receipt_long_outlined,
        );
      case 'debts':
        return (
          const Color(0xFFFEF2F2), // red-50
          const Color(0xFFEF4444), // red-500
          Icons.account_balance_wallet_outlined,
        );
      case 'summary':
      default:
        return (
          const Color(0xFFF1F5F9), // slate-100
          const Color(0xFF475569), // slate-600
          Icons.shopping_cart_outlined,
        );
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));
    final itemDate = DateTime(dt.year, dt.month, dt.day);

    if (itemDate == todayDate) {
      // Return e.g. 10:42 AM
      return DateFormat('hh:mm a').format(dt);
    } else if (itemDate == yesterdayDate) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(dt);
    }
  }
}
