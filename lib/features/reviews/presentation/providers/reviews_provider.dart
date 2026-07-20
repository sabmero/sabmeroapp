import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_entity.dart';

/// Identifies a review target: a product or a (completed) service booking.
class ReviewTarget {
  final String id;
  final String type; // 'product' | 'service'
  const ReviewTarget(this.id, this.type);

  @override
  bool operator ==(Object other) =>
      other is ReviewTarget && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}

/// Reviews for a product or a booking. Hits the GET endpoint via the repository
/// (which routes to /Reviews/product/{id} or /Reviews/booking/{id}).
final reviewsProvider = FutureProvider.family<List<ReviewEntity>, ReviewTarget>(
  (ref, target) async {
    return ref
        .watch(reviewRepositoryProvider)
        .getReviews(target.id, targetType: target.type);
  },
);

final submitReviewProvider =
    NotifierProvider<SubmitReviewNotifier, AsyncValue<void>>(
      SubmitReviewNotifier.new,
    );

class SubmitReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Submits a review. Returns a (success, message) record so the calling
  /// widget can show the backend's message (e.g. "You can only review products
  /// you've purchased.") instead of silently failing.
  Future<({bool success, String message})> submit({
    required String targetId,
    required String targetType,
    required double rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(reviewRepositoryProvider)
          .submitReview(
            targetId: targetId,
            targetType: targetType,
            rating: rating,
            comment: comment,
          );
      ref.invalidate(reviewsProvider(ReviewTarget(targetId, targetType)));
      state = const AsyncValue.data(null);
      AppLogger.info('Review submitted', tag: 'SubmitReviewNotifier');
      return (success: true, message: 'Review submitted.');
    } catch (e, st) {
      AppLogger.error(
        'Submit review failed',
        tag: 'SubmitReviewNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      return (success: false, message: _readableError(e));
    }
  }

  String _readableError(Object e) => e
      .toString()
      .replaceFirst('ServerFailure: ', '')
      .replaceFirst('AuthFailure: ', '')
      .replaceFirst('Exception: ', '');
}
