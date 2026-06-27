import 'package:gnade_app/src/imports/imports.dart';

class MoreSettingTile extends StatelessWidget {
  final String title;
  final dynamic icon; // Can be IconData or List<List<dynamic>>
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const MoreSettingTile({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            // Icon Background
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: AppIcon(
                  icon: icon,
                  color: iconColor,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            // Trailing Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
