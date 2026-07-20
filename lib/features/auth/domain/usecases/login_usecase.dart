import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String phone;
  final String password;
  const LoginParams({required this.phone, required this.password});
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return repository.login(phone: params.phone, password: params.password);
  }
}
