import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  final String phone;
  final String otp;
  const VerifyOtpParams({required this.phone, required this.otp});
}

class VerifyOtpUseCase implements UseCase<UserEntity, VerifyOtpParams> {
  final AuthRepository repository;
  const VerifyOtpUseCase(this.repository);

  @override
  Future<UserEntity> call(VerifyOtpParams params) {
    return repository.verifyOtp(phone: params.phone, otp: params.otp);
  }
}
