import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Provider for NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

/// State notifier for loading and managing notification list state
class NotificationsListNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final NotificationRepository _repository;

  NotificationsListNotifier({required NotificationRepository repository})
      : _repository = repository,
        super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    final result = await _repository.getNotifications();
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (list) => state = AsyncValue.data(list),
    );
  }

  Future<void> markAsRead(String id) async {
    final currentData = state.value;
    if (currentData == null) return;

    // Optimistic UI update
    final updatedList = currentData.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    state = AsyncValue.data(updatedList);

    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final currentData = state.value;
    if (currentData == null) return;

    // Optimistic UI update
    final updatedList = currentData.map((item) => item.copyWith(isRead: true)).toList();
    state = AsyncValue.data(updatedList);

    await _repository.markAllAsRead();
  }
}

/// Provider for notifications list
final notificationsListProvider = StateNotifierProvider<NotificationsListNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsListNotifier(repository: repository);
});

/// Provider for selected notification category filter chip
final selectedNotificationFilterProvider = StateProvider<String>((ref) => 'All');

/// Provider for filtering, sorting and grouping notifications by date sections
final filteredNotificationsProvider = Provider<AsyncValue<Map<String, List<NotificationItem>>>>((ref) {
  final listAsync = ref.watch(notificationsListProvider);
  final filter = ref.watch(selectedNotificationFilterProvider);

  return listAsync.whenData((list) {
    // 1. Filter by category
    final filtered = list.where((item) {
      if (filter == 'All') return true;
      final itemCategory = item.category.toLowerCase();
      final filterLower = filter.toLowerCase();
      // "Debts" maps to "debts"
      if (filterLower == 'debts') return itemCategory == 'debts';
      return itemCategory == filterLower;
    }).toList();

    // 2. Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 3. Group by date sections
    final todayList = <NotificationItem>[];
    final yesterdayList = <NotificationItem>[];
    final earlierList = <NotificationItem>[];

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    for (final item in filtered) {
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      if (itemDate == todayDate) {
        todayList.add(item);
      } else if (itemDate == yesterdayDate) {
        yesterdayList.add(item);
      } else {
        earlierList.add(item);
      }
    }

    return {
      if (todayList.isNotEmpty) 'Today': todayList,
      if (yesterdayList.isNotEmpty) 'Yesterday': yesterdayList,
      if (earlierList.isNotEmpty) 'Earlier': earlierList,
    };
  });
});
