import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenStorage,
  });

  @override
  Future<UserEntity> login({
    required String phone,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        phone: phone,
        password: password,
      );
      await localDataSource.cacheUser(result.user);
      return result.user;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await remoteDataSource.sendOtp(phone: phone);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyOtp(phone: phone, code: otp);
      await localDataSource.cacheUser(result.user);
      return result.user;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String address,
    required String password,
    String? email,
  }) async {
    try {
      final result = await remoteDataSource.register(
        fullName: name,
        phone: phone,
        address: address,
        password: password,
        email: email,
      );
      await localDataSource.cacheUser(result.user);
      return result.user;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> logout() async {
    // Tell the server to stop pushing this phone's notifications to the account
    // we're leaving (must run BEFORE the auth token is cleared).
    await remoteDataSource.clearFcmToken();
    await tokenStorage.clearToken();
    await localDataSource.clearUser();
    AppLogger.info('Logged out, cleared token + cache', tag: 'AuthRepo');
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // No token => not logged in.
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) return null;

    // Try the network first; fall back to cached user if offline.
    try {
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return user;
    } on AuthException {
      // Token expired/invalid - clear it.
      await tokenStorage.clearToken();
      await localDataSource.clearUser();
      return null;
    } catch (e) {
      AppLogger.warning(
        'getCurrentUser network failed, using cache',
        tag: 'AuthRepo',
      );
      return localDataSource.getCachedUser();
    }
  }

  @override
  Future<String> uploadKycDocument({required String filePath}) async {
    try {
      final path = await remoteDataSource.uploadKyc(filePath: filePath);
      AppLogger.info('KYC uploaded: $path', tag: 'AuthRepo');
      return path;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> registerFcmToken({required String token}) async {
    try {
      await remoteDataSource.registerFcmToken(token: token);
    } catch (e) {
      // Token registration must never crash the app — log and move on.
      AppLogger.warning(
        'FCM token registration failed: $e',
        tag: 'AuthRepository',
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});