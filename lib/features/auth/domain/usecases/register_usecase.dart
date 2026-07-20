import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String name;
  final String phone;
  final String address;
  final String password;
  final String? email;
  const RegisterParams({
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    this.email,
  });
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      phone: params.phone,
      address: params.address,
      password: params.password,
      email: params.email,
    );
  }
}
