import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Holds the user's chosen [ThemeMode] and persists it across launches.
///
/// Defaults to [ThemeMode.system] so the app follows the device until the user
/// makes an explicit choice in Settings.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(AppConstants.themeModeKey);
      if (stored != null) {
        state = _fromString(stored);
      }
    } catch (e, st) {
      AppLogger.error(
        'Failed to load theme mode',
        tag: 'ThemeModeNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeModeKey, mode.name);
    } catch (e, st) {
      AppLogger.error(
        'Failed to save theme mode',
        tag: 'ThemeModeNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
