import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.referenceId,
  });

  /// Parses one item of GET /api/Notifications:
  /// { id, title, body, type, referenceId, isRead, createdAt }
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      type: _typeFrom((json['type'] ?? '').toString()),
      isRead: json['isRead'] == true,
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      referenceId: json['referenceId']?.toString(),
    );
  }

  // Backend push types: order, order_new, order_status, order_assigned,
  // booking, booking_assigned, payment, vendorPayment, vendor_request(_new), promo.
  static NotificationType _typeFrom(String raw) {
    final t = raw.toLowerCase();
    if (t.contains('promo')) return NotificationType.promo;
    if (t.contains('booking') || t.contains('repair')) {
      return NotificationType.repair;
    }
    if (t.startsWith('order') || t.contains('payment')) {
      return NotificationType.order;
    }
    return NotificationType.system;
  }
}
