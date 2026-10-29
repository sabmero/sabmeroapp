import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../router/route_names.dart';
import '../utils/app_logger.dart';

/// Top-level background/terminated push handler.
///
/// MUST be a top-level (or static) function and annotated with
/// `@pragma('vm:entry-point')` so it survives tree-shaking and can run in the
/// background isolate. Registered from `main()` BEFORE `runApp`.
///
/// The system tray notification is drawn automatically by the OS when the FCM
/// payload contains a `notification` block, so here we only log. Any heavy work
/// (e.g. updating a local DB) can be done here too.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // A background isolate has its own memory — Firebase must be initialised here.
  await Firebase.initializeApp();
  AppLogger.info(
    'Background message: ${message.messageId} data=${message.data}',
    tag: 'FCM.bg',
  );
}

/// Handles everything FCM on the client:
///  - requests notification permission
///  - creates the Android notification channel
///  - shows a heads-up notification for FOREGROUND messages
///    (Android does not draw these automatically)
///  - routes the user to the right screen when a notification is tapped
///    (foreground, background, and terminated/cold-start)
class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Must match the channel referenced in AndroidManifest meta-data.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'Order, repair and promo updates from Sab Mero',
    importance: Importance.high,
  );

  /// Set by the app once GoRouter is ready so taps can navigate. Kept as a
  /// simple callback to avoid a hard dependency on go_router in this service.
  static void Function(String location)? _onNavigate;

  /// A tap that arrived before the router was ready (e.g. cold start). Consumed
  /// once [attachNavigator] is called.
  static RemoteMessage? _pendingTapMessage;

  static bool _initialised = false;

  /// Call from `main()` after `Firebase.initializeApp()`.
  static Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await _requestPermission();
    await _initLocalNotifications();

    // Show data even when the app is in the foreground on iOS.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // FOREGROUND: draw our own heads-up notification.
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // BACKGROUND (app open but backgrounded) → user taps notification.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // TERMINATED → app launched by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _pendingTapMessage = initialMessage;
    }

    final token = await getToken();
    AppLogger.info('FCM token: $token', tag: 'FCM');
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.info(
      'Notification permission: ${settings.authorizationStatus}',
      tag: 'FCM',
    );
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: (response) {
        final location = response.payload;
        if (location != null && location.isNotEmpty) {
          _navigate(location);
        }
      },
    );

    // Create the Android channel (no-op on iOS).
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      'Foreground message: ${message.messageId} data=${message.data}',
      tag: 'FCM',
    );

    final notification = message.notification;
    if (notification == null) return; // data-only message → nothing to show

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _routeFor(message),
    );
  }

  /// Registered by the app once the router exists. Flushes any tap that came in
  /// while the app was still starting up.
  static void attachNavigator(void Function(String location) onNavigate) {
    _onNavigate = onNavigate;
    final pending = _pendingTapMessage;
    if (pending != null) {
      _pendingTapMessage = null;
      _handleTap(pending);
    }
  }

  static void _handleTap(RemoteMessage message) {
    AppLogger.info(
      'Notification tapped: data=${message.data}',
      tag: 'FCM',
    );
    _navigate(_routeFor(message));
  }

  static void _navigate(String location) {
    final nav = _onNavigate;
    if (nav == null) {
      // Router not ready yet — remember and replay once attached.
      return;
    }
    nav(location);
  }

  /// Maps an FCM payload to an in-app route. The backend sends a `type` and
  /// optional `referenceId` in the data block; adjust the keys to match your
  /// server. Falls back to the notifications tab.
  static String _routeFor(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString().toLowerCase();
    final refId =
        (data['referenceId'] ?? data['id'] ?? data['orderId'] ?? '').toString();

    switch (type) {
      case 'order':
      case 'order_new': // vendor/admin: a new order arrived
      case 'order_status': // vendor/admin: status of an order changed
        return refId.isNotEmpty
            ? RouteNames.orderDetail.replaceFirst(':id', refId)
            : RouteNames.orderList;
      case 'repair':
        return refId.isNotEmpty
            ? RouteNames.repairTracking.replaceFirst(':id', refId)
            : RouteNames.myRepairs;
      case 'promo':
        return RouteNames.home;
      default:
        return RouteNames.notifications;
    }
  }

  static Future<String?> getToken() => _messaging.getToken();

  static void onTokenRefresh(void Function(String token) callback) {
    _messaging.onTokenRefresh.listen(callback);
  }
}
