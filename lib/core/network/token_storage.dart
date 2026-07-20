import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.authTokenKey, value: token);
    } catch (e, st) {
      AppLogger.error('Failed to save token', tag: 'TokenStorage', error: e, stackTrace: st);
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.authTokenKey);
    } catch (e, st) {
      AppLogger.error('Failed to read token', tag: 'TokenStorage', error: e, stackTrace: st);
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: AppConstants.authTokenKey);
    } catch (e, st) {
      AppLogger.error('Failed to clear token', tag: 'TokenStorage', error: e, stackTrace: st);
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => const TokenStorage(FlutterSecureStorage()),
);
