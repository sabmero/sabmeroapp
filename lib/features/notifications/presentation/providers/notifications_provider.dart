import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationEntity>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationEntity>> {
  @override
  Future<List<NotificationEntity>> build() async {
    return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider))(
      const NoParams(),
    );
  }

  Future<void> markAsRead(String id) async {
    try {
      await MarkAsReadUseCase(ref.read(notificationRepositoryProvider))(id);
      final current = state.asData?.value ?? [];
      state = AsyncValue.data(
        current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
      );
    } catch (e, st) {
      AppLogger.error('Mark read failed', tag: 'NotificationsNotifier', error: e, stackTrace: st);
    }
  }

  Future<void> markAllRead() async {
    final current = state.asData?.value ?? [];
    for (final n in current.where((n) => !n.isRead)) {
      await MarkAsReadUseCase(ref.read(notificationRepositoryProvider))(n.id);
    }
    state = AsyncValue.data(
      current.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsNotifierProvider);
  return state.asData?.value?.where((n) => !n.isRead).length ?? 0;
});
