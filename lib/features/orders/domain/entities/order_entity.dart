class OrderItemEntity {
  final String productId;
  final String productName;
  final String productImage;
  final String variantLabel;
  final double unitPrice;
  final int quantity;

  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.variantLabel,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final String deliveryAddress;
  final String paymentMethod;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.createdAt,
    this.estimatedDelivery,
  });

  String get statusLabel => switch (status) {
    OrderStatus.pending => 'Pending',
    OrderStatus.confirmed => 'Confirmed',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };
  String get shortId =>
      id.length > 4 ? id.substring(4).toUpperCase() : id.toUpperCase();

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  int get statusStep => status.index.clamp(0, 4);
}
