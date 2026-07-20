import '../../../../core/usecases/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetReviewsUseCase implements UseCase<List<ReviewEntity>, String> {
  final ReviewRepository repository;
  const GetReviewsUseCase(this.repository);
  @override
  Future<List<ReviewEntity>> call(String targetId) =>
      repository.getReviews(targetId);
}
