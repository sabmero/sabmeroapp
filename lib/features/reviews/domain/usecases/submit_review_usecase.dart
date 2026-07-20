import '../../../../core/usecases/usecase.dart';
import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class SubmitReviewParams {
  final String targetId;
  final String targetType;
  final double rating;
  final String? comment;
  const SubmitReviewParams({
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.comment,
  });
}

class SubmitReviewUseCase implements UseCase<ReviewEntity, SubmitReviewParams> {
  final ReviewRepository repository;
  const SubmitReviewUseCase(this.repository);
  @override
  Future<ReviewEntity> call(SubmitReviewParams params) =>
      repository.submitReview(
        targetId: params.targetId,
        targetType: params.targetType,
        rating: params.rating,
        comment: params.comment,
      );
}
