import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final String? token;
  const AuthResult({required this.user, this.token});
}

abstract class AuthRemoteDataSource {
  Future<AuthResult> login({required String phone, required String password});
  Future<void> sendOtp({required String phone});
  Future<AuthResult> verifyOtp({required String phone, required String code});
  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String address,
    String? email,
    String? password,
  });
  Future<UserModel> getCurrentUser();
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> registerFcmToken({required String token});
  Future<void> clearFcmToken();
  Future<String> uploadKyc({required String filePath});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient, this._tokenStorage);

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  // The API wraps payloads as { success, message, data: {...} }.
  // This pulls the user + token out regardless of nesting.
  AuthResult _parseAuthResponse(dynamic body) {
    final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;

    final token = data['token'] as String?;
    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;

    return AuthResult(user: UserModel.fromJson(userJson), token: token);
  }

  @override
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );
      final result = _parseAuthResponse(response.data);
      if (result.token != null) {
        await _tokenStorage.saveToken(result.token!);
      }
      AppLogger.info(
        'Login success: ${result.user.phone}',
        tag: 'AuthRemoteDataSource',
      );
      return result;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await _apiClient.dio.post(ApiConstants.sendOtp, data: {'phone': phone});
      AppLogger.info('OTP sent to $phone', tag: 'AuthRemoteDataSource');
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<AuthResult> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.verifyOtp,
        data: {'phone': phone, 'code': code},
      );
      final result = _parseAuthResponse(response.data);
      if (result.token != null) {
        await _tokenStorage.saveToken(result.token!);
      }
      AppLogger.info('OTP verified: $phone', tag: 'AuthRemoteDataSource');
      return result;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String address,
    String? email,
    String? password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'fullName': fullName,
          'phone': phone,
          'address': address,
          if (email != null && email.isNotEmpty) 'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
          'role': 'Customer',
        },
      );
      final result = _parseAuthResponse(response.data);
      if (result.token != null) {
        await _tokenStorage.saveToken(result.token!);
      }
      AppLogger.info('Register success: $phone', tag: 'AuthRemoteDataSource');
      return result;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.me);
      final body = response.data;
      final map = body is Map<String, dynamic> ? body : <String, dynamic>{};
      final data = map['data'] is Map<String, dynamic>
          ? map['data'] as Map<String, dynamic>
          : map;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> uploadKyc({required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadKyc,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      final path = data['path'] as String? ?? '';
      AppLogger.info(
        'KYC document uploaded: $path',
        tag: 'AuthRemoteDataSource',
      );
      return path;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      AppLogger.info(
        'Password reset code requested for $email',
        tag: 'AuthRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      AppLogger.info('Password reset for $email', tag: 'AuthRemoteDataSource');
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> registerFcmToken({required String token}) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.fcmToken,
        data: {'token': token},
      );
      AppLogger.info(
        'FCM token registered with backend',
        tag: 'AuthRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> clearFcmToken() async {
    try {
      await _apiClient.dio.delete(ApiConstants.fcmToken);
    } catch (_) {
      // Best effort — logout must never fail because of this.
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});