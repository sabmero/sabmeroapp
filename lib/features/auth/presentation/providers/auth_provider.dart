import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/upload_kyc_document_usecase.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    final useCase = GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
    return useCase(const NoParams());
  }

  /// Pushes an already-fetched user straight into the shared auth state so the
  /// whole app (profile header, drawer, etc.) reflects it immediately — no
  /// refetch, no race with the async rebuild. Used after an Edit Profile save.
  void setUser(UserEntity user) {
    state = AsyncValue.data(user);
  }

  Future<void> login({required String phone, required String password}) async {
    try {
      final user = await LoginUseCase(ref.read(authRepositoryProvider))(
        LoginParams(phone: phone, password: password),
      );
      AppLogger.info('Login success: ${user.name}', tag: 'AuthNotifier');
      state = AsyncValue.data(user);
    } catch (e, st) {
      AppLogger.error(
        'Login failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
      // Do NOT push an error state onto the shared provider - that makes the
      // router bounce to splash. Let the screen handle the failure.
      rethrow;
    }
  }

  Future<void> sendOtp({required String phone}) async {
    try {
      await ref.read(authRepositoryProvider).sendOtp(phone: phone);
    } catch (e, st) {
      AppLogger.error(
        'Send OTP failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    try {
      final user = await VerifyOtpUseCase(ref.read(authRepositoryProvider))(
        VerifyOtpParams(phone: phone, otp: otp),
      );
      AppLogger.info('OTP verified: ${user.phone}', tag: 'AuthNotifier');
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      AppLogger.error(
        'OTP verification failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
      _lastError = e;
      return false;
    }
  }

  /// Holds the most recent login/otp failure so screens can read a message
  /// without the error living on the shared provider state.
  Object? _lastError;
  Object? consumeLastError() {
    final e = _lastError;
    _lastError = null;
    return e;
  }

  Future<void> register({
    required String name,
    required String phone,
    required String address,
    required String password,
    String? email,
  }) async {
    try {
      final user = await RegisterUseCase(ref.read(authRepositoryProvider))(
        RegisterParams(
          name: name,
          phone: phone,
          address: address,
          password: password,
          email: email,
        ),
      );
      AppLogger.info('Register success: ${user.name}', tag: 'AuthNotifier');
      state = AsyncValue.data(user);
    } catch (e, st) {
      AppLogger.error(
        'Register failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await LogoutUseCase(ref.read(authRepositoryProvider))(const NoParams());
      AppLogger.info('Logged out', tag: 'AuthNotifier');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      AppLogger.error(
        'Logout failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
      state = const AsyncValue.data(null);
    }
  }

  Future<void> uploadKycDocument({required String filePath}) async {
    try {
      await UploadKycDocumentUseCase(ref.read(authRepositoryProvider))(
        UploadKycParams(filePath: filePath),
      );
      AppLogger.info('KYC uploaded', tag: 'AuthNotifier');
      ref.invalidateSelf();
    } catch (e, st) {
      AppLogger.error(
        'KYC upload failed',
        tag: 'AuthNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    await ref.read(authRepositoryProvider).forgotPassword(email: email);
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await ref.read(authRepositoryProvider).resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
        );
  }

  /// Sends the current device's FCM token to the backend. Safe to call any
  /// time after login — failures are swallowed inside the repository.
  Future<void> registerFcmToken(String token) async {
    await ref.read(authRepositoryProvider).registerFcmToken(token: token);
  }
}

final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  final local = ref.read(authLocalDataSourceProvider);
  return local.hasSeenOnboarding();
});