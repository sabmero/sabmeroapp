import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) => repository.logout();
}
