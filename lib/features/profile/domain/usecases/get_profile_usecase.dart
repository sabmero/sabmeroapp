import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<UserEntity, NoParams> {
  final ProfileRepository repository;
  const GetProfileUseCase(this.repository);
  @override
  Future<UserEntity> call(NoParams p) => repository.getProfile();
}

class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? imagePath;
  const UpdateProfileParams({this.name, this.email, this.imagePath});
}

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final ProfileRepository repository;
  const UpdateProfileUseCase(this.repository);
  @override
  Future<UserEntity> call(UpdateProfileParams p) => repository.updateProfile(
    name: p.name,
    email: p.email,
    imagePath: p.imagePath,
  );
}

class GetKycStatusUseCase implements UseCase<String, NoParams> {
  final ProfileRepository repository;
  const GetKycStatusUseCase(this.repository);
  @override
  Future<String> call(NoParams p) => repository.getKycStatus();
}

class GetAddressesUseCase implements UseCase<List<dynamic>, NoParams> {
  final ProfileRepository repository;
  const GetAddressesUseCase(this.repository);
  @override
  Future<List<dynamic>> call(NoParams p) => repository.getAddresses();
}
