import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'notification_prefs_provider.dart';
import 'notifications_provider.dart';

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    AppLogger.info('FCM token: $token', tag: 'FCMProvider');
    return token;
  } catch (e, st) {
    AppLogger.error(
      'FCM token failed',
      tag: 'FCMProvider',
      error: e,
      stackTrace: st,
    );
    return null;
  }
});

/// Sends the FCM device token to POST /api/auth/fcm-token whenever the user
/// is logged in, and again whenever Firebase rotates the token. Watched once
/// from SabmeroApp so it stays alive for the whole session.
final fcmRegistrationProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.asData?.value;
  if (user == null) return; // not logged in yet — re-runs after login

  // A push arrived while the app is open → refresh the Alerts list.
  final onMessageSub = FirebaseMessaging.onMessage.listen((_) {
    ref.invalidate(notificationsNotifierProvider);
  });
  ref.onDispose(onMessageSub.cancel);

  Future<void> register() async {
    final token = await FcmService.getToken();
    if (token == null) return;
    await ref.read(authNotifierProvider.notifier).registerFcmToken(token);
    // Tell the backend which Settings switches this phone has on/off.
    await ref.read(notificationPrefsProvider.notifier).syncToServer();
  }

  register();
  FcmService.onTokenRefresh((token) {
    ref.read(authNotifierProvider.notifier).registerFcmToken(token);
  });
});
