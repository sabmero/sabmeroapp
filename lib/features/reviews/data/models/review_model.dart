import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.targetId,
    required super.targetType,
    required super.rating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'];
    final bookingId = json['serviceBookingId'];
    final isProduct = productId != null;
    return ReviewModel(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      userName: json['reviewerName'] as String? ?? 'User',
      userAvatar: null,
      targetId: '${isProduct ? productId : (bookingId ?? '')}',
      targetType: isProduct ? 'product' : 'service',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
