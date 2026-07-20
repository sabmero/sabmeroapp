class ReviewEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String targetId;
  final String targetType;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
