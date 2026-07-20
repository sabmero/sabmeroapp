import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews(String targetId, {String targetType});
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  ReviewRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  bool _isProduct(String targetType) => targetType.toLowerCase() == 'product';

  @override
  Future<List<ReviewModel>> getReviews(
    String targetId, {
    String targetType = 'product',
  }) async {
    try {
      final base = _isProduct(targetType)
          ? ApiConstants.reviewsForProduct
          : ApiConstants.reviewsForBooking;
      final response = await _apiClient.dio.get('$base$targetId');
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  }) async {
    try {
      final id = int.tryParse(targetId);
      final body = {
        if (_isProduct(targetType)) 'productId': id else 'serviceBookingId': id,
        'rating': rating.round(),
        'comment': ?comment,
      };
      final response = await _apiClient.dio.post(
        ApiConstants.reviews,
        data: body,
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info('Review submitted for $targetId', tag: 'ReviewDataSource');
      return ReviewModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>(
  (ref) => ReviewRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
