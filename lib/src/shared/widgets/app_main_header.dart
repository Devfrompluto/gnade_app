import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

import 'package:gnade_app/src/features/notifications/presentation/providers/notifications_provider.dart';

class AppMainHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppMainHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final session = ref.watch(sessionProvider);
    final user = session.user;
    final userName = user?.name ?? '';
    final initials = userName.isNotEmpty
        ? userName
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'G';

    final businessAsync = ref.watch(businessProfileProvider);
    final businessName = businessAsync.value?.name ?? 'Kinetic Retail';

    final unreadCount = ref.watch(notificationsListProvider).maybeWhen(
          data: (list) => list.where((item) => !item.isRead).length,
          orElse: () => 0,
        );

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.pagePadding.w,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A), // Dark blue
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (initials.length > 1) ? 12.sp : 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Business Switch Dropdown
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          businessName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification Bell Badge
          GestureDetector(
            onTap: () => context.push(AppRoutes.notifications),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: AppIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    size: 16.sp,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -2.h,
                    right: -2.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48), // Vibrant red badge
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.w,
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
