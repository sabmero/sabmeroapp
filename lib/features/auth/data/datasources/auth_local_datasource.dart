import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
  Future<bool> hasSeenOnboarding();
  Future<void> markOnboardingSeen();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(AppConstants.cachedUserKey);
      if (json == null) return null;
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e, st) {
      AppLogger.error(
        'Failed to load cached user',
        tag: 'AuthLocalDataSource',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.cachedUserKey,
        jsonEncode(user.toJson()),
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to cache user',
        tag: 'AuthLocalDataSource',
        error: e,
        stackTrace: st,
      );
      throw CacheException(message: 'Failed to save user data.');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.cachedUserKey);
      await prefs.remove(AppConstants.authTokenKey);
    } catch (e, st) {
      AppLogger.error(
        'Failed to clear user',
        tag: 'AuthLocalDataSource',
        error: e,
        stackTrace: st,
      );
      throw CacheException(message: 'Failed to clear user data.');
    }
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingSeenKey) ?? false;
  }

  @override
  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingSeenKey, true);
  }
}

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (_) => AuthLocalDataSourceImpl(),
);
