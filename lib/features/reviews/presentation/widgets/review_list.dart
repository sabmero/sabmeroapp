import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/reviews_provider.dart';
import 'rating_input.dart';
import 'review_card.dart';

class ReviewList extends ConsumerStatefulWidget {
  const ReviewList({
    super.key,
    required this.targetId,
    required this.targetName,
    this.targetType = 'product',
    this.canWrite = true,
  });

  // Backward-compatible product constructor.
  ReviewList.product({
    Key? key,
    required String productId,
    required String productName,
  }) : this(
         key: key,
         targetId: productId,
         targetName: productName,
         targetType: 'product',
       );

  final String targetId;
  final String targetName;

  /// 'product' or 'service' (a completed booking).
  final String targetType;

  /// Hide the write-a-review form when the user isn't eligible (e.g. a service
  /// that isn't completed yet).
  final bool canWrite;

  @override
  ConsumerState<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends ConsumerState<ReviewList> {
  bool _showForm = false;
  bool _submitting = false;
  double _myRating = 0;
  final _commentController = TextEditingController();

  ReviewTarget get _target => ReviewTarget(widget.targetId, widget.targetType);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_myRating == 0) {
      _showSnack('Please select a rating first.', isError: true);
      return;
    }
    setState(() => _submitting = true);
    final result = await ref
        .read(submitReviewProvider.notifier)
        .submit(
          targetId: widget.targetId,
          targetType: widget.targetType,
          rating: _myRating,
          comment: _commentController.text.trim().isNotEmpty
              ? _commentController.text.trim()
              : null,
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      setState(() {
        _showForm = false;
        _myRating = 0;
        _commentController.clear();
      });
      _showSnack('Thanks! Your review has been posted.');
    } else {
      // Surface the backend reason (e.g. "You can only review products you've
      // purchased.") instead of failing silently.
      _showSnack(result.message, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.errorColor
            : AppColors.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(reviewsProvider(_target));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (widget.canWrite)
              TextButton.icon(
                onPressed: () => setState(() => _showForm = !_showForm),
                icon: Icon(
                  _showForm ? Icons.close : Icons.rate_review_outlined,
                  size: 18,
                ),
                label: Text(_showForm ? 'Cancel' : 'Write Review'),
              ),
          ],
        ),
        if (_showForm && widget.canWrite) ...[
          const SizedBox(height: 8),
          Text('Your Rating', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          RatingInput(
            rating: _myRating,
            onRatingChanged: (r) => setState(() => _myRating = r),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience (optional)',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Review'),
          ),
          const SizedBox(height: 16),
        ],
        reviewsState.when(
          data: (reviews) => reviews.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : Column(
                  children: reviews.map((r) => ReviewCard(review: r)).toList(),
                ),
          loading: () => const TileListSkeleton(itemCount: 3),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
