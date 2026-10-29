import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabmeroapp/core/constants/api_constants.dart';
import 'package:sabmeroapp/core/constants/app_constants.dart';
import 'package:sabmeroapp/core/network/api_client.dart';
import 'package:sabmeroapp/core/utils/app_logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefs {
  const NotificationPrefs({
    required this.pushNotifications,
    required this.promotionalAlerts,
  });

  final bool pushNotifications;
  final bool promotionalAlerts;

  NotificationPrefs copyWith({
    bool? pushNotifications,
    bool? promotionalAlerts,
  }) {
    return NotificationPrefs(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      promotionalAlerts: promotionalAlerts ?? this.promotionalAlerts,
    );
  }
}

class NotificationPrefsNotifier extends Notifier<NotificationPrefs> {
  // Completes once the saved switches have been read from SharedPreferences,
  // so a server sync never sends the temporary defaults.
  late Future<void> _ready;

  @override
  NotificationPrefs build() {
    _ready = _load();
    return const NotificationPrefs(
      pushNotifications: true,
      promotionalAlerts: false,
    );
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = NotificationPrefs(
        pushNotifications:
            prefs.getBool(AppConstants.pushNotificationsKey) ?? true,
        promotionalAlerts:
            prefs.getBool(AppConstants.promotionalAlertsKey) ?? false,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to load notification preferences',
        tag: 'NotificationPrefsNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setPushNotifications(bool value) async {
    state = state.copyWith(pushNotifications: value);
    await _save(AppConstants.pushNotificationsKey, value);
    await _pushToServer();
  }

  Future<void> setPromotionalAlerts(bool value) async {
    state = state.copyWith(promotionalAlerts: value);
    await _save(AppConstants.promotionalAlertsKey, value);
    await _pushToServer();
  }

  /// Sends the saved switches to the backend. Called after login (see
  /// fcmRegistrationProvider) so the server always knows what this phone chose.
  /// The server uses them to skip push / promo notifications.
  Future<void> syncToServer() async {
    await _ready;
    await _pushToServer();
  }

  // PUT /api/Auth/notification-settings — best effort, never throws.
  Future<void> _pushToServer() async {
    try {
      await ref.read(apiClientProvider).dio.put(
        ApiConstants.notificationSettings,
        data: {
          'pushEnabled': state.pushNotifications,
          'promoAlertsEnabled': state.promotionalAlerts,
        },
      );
      AppLogger.info(
        'Notification settings synced with backend',
        tag: 'NotificationPrefsNotifier',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to sync notification settings',
        tag: 'NotificationPrefsNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _save(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e, st) {
      AppLogger.error(
        'Failed to save notification preference',
        tag: 'NotificationPrefsNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsNotifier, NotificationPrefs>(
      NotificationPrefsNotifier.new,
    );
