enum RiderDeliveryStatus { dispatched, delivered, cancelled }

RiderDeliveryStatus riderDeliveryStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'delivered':
      return RiderDeliveryStatus.delivered;
    case 'cancelled':
    case 'canceled':
      return RiderDeliveryStatus.cancelled;
    case 'dispatched':
    default:
      return RiderDeliveryStatus.dispatched;
  }
}

class RiderDeliveryItemEntity {
  final String productName;
  final int quantity;

  const RiderDeliveryItemEntity({
    required this.productName,
    required this.quantity,
  });
}

/// An order that has been assigned to the logged-in rider for delivery.
/// Carries the customer's contact details and delivery address.
class RiderDeliveryEntity {
  final String id;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final List<RiderDeliveryItemEntity> items;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final RiderDeliveryStatus status;
  final DateTime createdAt;

  const RiderDeliveryEntity({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
  });

  String get statusLabel => switch (status) {
    RiderDeliveryStatus.dispatched => 'Out for Delivery',
    RiderDeliveryStatus.delivered => 'Delivered',
    RiderDeliveryStatus.cancelled => 'Cancelled',
  };

  bool get isActive => status == RiderDeliveryStatus.dispatched;

  /// Cash the rider needs to collect from the customer on delivery.
  bool get isCashOnDelivery =>
      paymentMethod.toUpperCase() == 'COD' && paymentStatus.toLowerCase() != 'paid';
}
