import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  const ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReviewEntity>> getReviews(
    String targetId, {
    String targetType = 'product',
  }) async {
    try {
      return List<ReviewEntity>.from(
        await remoteDataSource.getReviews(targetId, targetType: targetType),
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<ReviewEntity> submitReview({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  }) async {
    try {
      return await remoteDataSource.submitReview(
        targetId: targetId,
        targetType: targetType,
        rating: rating,
        comment: comment,
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(ref.watch(reviewRemoteDataSourceProvider));
});
