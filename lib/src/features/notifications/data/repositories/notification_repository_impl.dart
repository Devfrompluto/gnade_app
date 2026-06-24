import 'package:gnade_app/src/utils/utils.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  // Store items in memory so read status persists during app session
  late final List<NotificationItem> _mockNotifications;

  NotificationRepositoryImpl() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    _mockNotifications = [
      NotificationItem(
        id: '1',
        title: 'New Sale Recorded',
        description: 'Receipt #4829 completed for ₦12,500 by John Doe. Payment via POS.',
        timestamp: DateTime(today.year, today.month, today.day, 10, 42),
        isRead: false,
        category: 'sales',
      ),
      NotificationItem(
        id: '2',
        title: 'Low Stock Alert',
        description: 'Premium Rice (50kg) is down to 2 bags. Reorder soon to prevent stockout.',
        timestamp: DateTime(today.year, today.month, today.day, 9, 15),
        isRead: false,
        category: 'stock',
      ),
      NotificationItem(
        id: '3',
        title: 'Expense Logged',
        description: 'Transportation expense of ₦1,500 recorded by Shop Manager.',
        timestamp: DateTime(today.year, today.month, today.day, 8, 30),
        isRead: false,
        category: 'expenses',
      ),
      NotificationItem(
        id: '4',
        title: 'Payment Overdue',
        description: 'Customer Sarah M. missed payment of ₦5,000 due yesterday.',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 0),
        isRead: true,
        category: 'debts',
      ),
      NotificationItem(
        id: '5',
        title: 'Daily Summary',
        description: 'Total sales for yesterday: ₦142,000 across 34 transactions.',
        timestamp: DateTime(yesterday.year, yesterday.month, yesterday.day, 20, 0),
        isRead: true,
        category: 'summary',
      ),
    ];
  }

  @override
  FutureEither<List<NotificationItem>> getNotifications() async {
    return runTask(() async => List<NotificationItem>.from(_mockNotifications));
  }

  @override
  FutureEither<void> markAsRead(String id) async {
    return runTask(() async {
      final index = _mockNotifications.indexWhere((item) => item.id == id);
      if (index != -1) {
        _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
      }
    });
  }

  @override
  FutureEither<void> markAllAsRead() async {
    return runTask(() async {
      for (var i = 0; i < _mockNotifications.length; i++) {
        _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
      }
    });
  }
}
