import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // GET /api/Notifications → { success, data: [ ... ] }
  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final res = await _apiClient.dio.get(ApiConstants.notifications);
      final list = _apiClient.unwrapList(res.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  // POST /api/Notifications/{id}/read
  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.notifications}/$notificationId/read',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  // POST /api/Notifications/read-all
  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post(ApiConstants.notificationsReadAll);
      AppLogger.info(
        'All notifications marked as read',
        tag: 'NotificationDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>(
      (ref) => NotificationRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );
