import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UploadKycParams {
  final String filePath;
  const UploadKycParams({required this.filePath});
}

class UploadKycDocumentUseCase implements UseCase<String, UploadKycParams> {
  final AuthRepository repository;
  const UploadKycDocumentUseCase(this.repository);

  @override
  Future<String> call(UploadKycParams params) =>
      repository.uploadKycDocument(filePath: params.filePath);
}
