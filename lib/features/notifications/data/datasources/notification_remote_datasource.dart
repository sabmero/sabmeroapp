import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/notification_model.dart';

// NOTE: The backend exposes no notifications endpoint. Until one exists, this
// returns an empty list rather than fabricating data. When the API is added,
// inject ApiClient here and call it exactly like the other datasources.
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl();

  @override
  Future<List<NotificationModel>> getNotifications() async {
    AppLogger.info(
      'No notifications endpoint on backend; returning empty list.',
      tag: 'NotificationDataSource',
    );
    return const [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // No-op until a backend endpoint exists.
    AppLogger.info(
      'markAsRead is a no-op (no backend endpoint)',
      tag: 'NotificationDataSource',
    );
  }
}

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
      (_) => const NotificationRemoteDataSourceImpl(),
    );
