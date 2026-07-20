import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  @override
  Future<UserEntity?> call(NoParams params) => repository.getCurrentUser();
}
