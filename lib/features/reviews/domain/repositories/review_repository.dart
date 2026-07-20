import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getReviews(String targetId, {String targetType});
  Future<ReviewEntity> submitReview({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  });
}
