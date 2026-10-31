enum NotificationType { order, repair, promo, system }

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? referenceId;

  /// Backend type string (order_new, booking, promo ...). Used to pick the screen
  /// to open when the notification is tapped.
  final String rawType;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.referenceId,
    this.rawType = '',
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        body: body,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        referenceId: referenceId,
        rawType: rawType,
      );
}
