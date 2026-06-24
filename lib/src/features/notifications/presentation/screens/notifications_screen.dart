import 'package:gnade_app/src/imports/imports.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_filters.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(filteredNotificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: AppTopBar(
        title: 'Notifications',
        centerTitle: true,
        titleWidget: Text(
          'Notifications',
          style: TextStyle(
            color: const Color(0xFF0F172A), // Dark blue/slate
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: TextButton(
              onPressed: () {
                ref.read(notificationsListProvider.notifier).markAllAsRead();
                showGlobalToast(message: 'All notifications marked as read');
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: const Color(0xFF2563EB), // Blue color
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),
            // 1. Horizontal Category Filter Chips
            const NotificationFilters(),
            SizedBox(height: 12.h),

            // 2. Notifications Simple Grouped List
            Expanded(
              child: groupedAsync.when(
                loading: () => const Center(child: AppLoading()),
                error: (err, stack) => AppErrorWidget(
                  message: 'Could not load notifications',
                  onRetry: () => ref.read(notificationsListProvider.notifier).loadNotifications(),
                ),
                data: (groupedMap) {
                  if (groupedMap.isEmpty) {
                    return const AppEmptyState(
                      title: 'No notifications',
                      subtitle: 'You are all caught up! New alerts will appear here.',
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                    itemCount: groupedMap.keys.length,
                    itemBuilder: (context, sectionIndex) {
                      final sectionKey = groupedMap.keys.elementAt(sectionIndex);
                      final items = groupedMap[sectionKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header (e.g. Today, Yesterday)
                          Padding(
                            padding: EdgeInsets.only(left: 4.w, top: 12.h, bottom: 8.h),
                            child: Text(
                              sectionKey,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),

                          // Notification tiles in section
                          ...items.map((item) => NotificationTile(
                                key: ValueKey(item.id),
                                item: item,
                              )),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
