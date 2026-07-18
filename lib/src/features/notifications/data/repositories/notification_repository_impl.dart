import 'package:gnade_app/src/utils/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  FutureEither<List<NotificationItem>> getNotifications(String businessId) {
    return runTask(() async {
      final data = await _client
          .from('notification_logs')
          .select('*')
          .eq('business_id', businessId)
          .order('created_at', ascending: false)
          .limit(100);

      return data.map((row) => NotificationItem.fromMap(row)).toList();
    });
  }

  @override
  FutureEither<void> markAsRead(String id) {
    return runTask(() async {
      await _client
          .from('notification_logs')
          .update({'read': true})
          .eq('id', id);
    });
  }

  @override
  FutureEither<void> markAllAsRead(String businessId) {
    return runTask(() async {
      await _client
          .from('notification_logs')
          .update({'read': true})
          .eq('business_id', businessId)
          .eq('read', false);
    });
  }
}
