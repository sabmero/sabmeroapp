import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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

  Future<void> register() async {
    final token = await FcmService.getToken();
    if (token == null) return;
    await ref.read(authNotifierProvider.notifier).registerFcmToken(token);
  }

  register();
  FcmService.onTokenRefresh((token) {
    ref.read(authNotifierProvider.notifier).registerFcmToken(token);
  });
});
