import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/utils/app_logger.dart';
import 'features/notifications/presentation/providers/fcm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      details.exceptionAsString(),
      tag: 'FlutterError',
      stackTrace: details.stack,
    );
  };

  try {
    await Firebase.initializeApp();
    // Background/terminated push handler — must be registered before runApp.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FcmService.init();
  } catch (e, st) {
    AppLogger.error(
      'Firebase init failed',
      tag: 'Main',
      error: e,
      stackTrace: st,
    );
  }

  runApp(const ProviderScope(child: SabmeroApp()));
}

class SabmeroApp extends ConsumerWidget {
  const SabmeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Registers the FCM device token with the backend whenever the user is
    // logged in, and re-registers on token refresh.
    ref.watch(fcmRegistrationProvider);

    // Lets notification taps (foreground/background/terminated) deep-link into
    // the app once the router is available.
    FcmService.attachNavigator(router.go);

    return MaterialApp.router(
      title: 'sabmero',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
