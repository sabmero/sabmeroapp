import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String phone, required String password});
  Future<void> sendOtp({required String phone});
  Future<UserEntity> verifyOtp({required String phone, required String otp});
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String address,
    required String password,
    String? email,
  });
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<void> registerFcmToken({required String token});
  Future<String> uploadKycDocument({required String filePath});
}
