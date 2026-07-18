import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
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
  final String _businessId;

  NotificationsListNotifier({
    required NotificationRepository repository,
    required String businessId,
  })  : _repository = repository,
        _businessId = businessId,
        super(const AsyncValue.loading()) {
    if (_businessId.isNotEmpty) {
      loadNotifications();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadNotifications() async {
    if (_businessId.isEmpty) return;
    state = const AsyncValue.loading();
    final result = await _repository.getNotifications(_businessId);
    if (!mounted) return;
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
    if (_businessId.isEmpty) return;
    final currentData = state.value;
    if (currentData == null) return;

    // Optimistic UI update
    final updatedList = currentData.map((item) => item.copyWith(isRead: true)).toList();
    state = AsyncValue.data(updatedList);

    await _repository.markAllAsRead(_businessId);
  }
}

/// Provider for notifications list
final notificationsListProvider = StateNotifierProvider<NotificationsListNotifier, AsyncValue<List<NotificationItem>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  final sessionState = ref.watch<SessionState>(sessionProvider);
  final businessId = sessionState.user?.businessId ?? '';
  
  return NotificationsListNotifier(
    repository: repository,
    businessId: businessId,
  );
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
