import 'package:gnade_app/src/utils/utils.dart';
import '../entities/notification_item.dart';

abstract class NotificationRepository {
  /// Fetches the list of notifications
  FutureEither<List<NotificationItem>> getNotifications();

  /// Marks a specific notification as read
  FutureEither<void> markAsRead(String id);

  /// Marks all notifications as read
  FutureEither<void> markAllAsRead();
}
