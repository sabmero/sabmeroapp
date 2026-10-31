import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final notificationsNotifierProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationEntity>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationEntity>> {
  @override
  Future<List<NotificationEntity>> build() async {
    // Reload whenever the logged-in user changes; nothing to load when logged out.
    final user = ref.watch(authNotifierProvider).asData?.value;
    if (user == null) return const [];

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
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead();
      final current = state.asData?.value ?? [];
      state = AsyncValue.data(
        current.map((n) => n.copyWith(isRead: true)).toList(),
      );
    } catch (e, st) {
      AppLogger.error('Mark all read failed', tag: 'NotificationsNotifier', error: e, stackTrace: st);
    }
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsNotifierProvider);
  return state.asData?.value?.where((n) => !n.isRead).length ?? 0;
});
