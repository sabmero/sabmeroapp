import '../../../shop/data/models/category_model.dart' show resolveImageUrl;
import '../../domain/entities/order_entity.dart';

OrderStatus orderStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'confirmed':
      return OrderStatus.confirmed;
    case 'processing':
      return OrderStatus.processing;
    case 'dispatched':
    case 'shipped':
    case 'ontheway':
      return OrderStatus.shipped;
    case 'delivered':
    case 'completed':
      return OrderStatus.delivered;
    case 'cancelled':
    case 'canceled':
      return OrderStatus.cancelled;
    case 'pending':
    default:
      return OrderStatus.pending;
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.variantLabel,
    required super.unitPrice,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final size = json['selectedSize'] as String?;
    final color = json['selectedColor'] as String?;
    final label = [
      size,
      color,
    ].where((e) => e != null && e.isNotEmpty).join(' / ');
    return OrderItemModel(
      productId: '${json['productId'] ?? ''}',
      productName: json['productName'] as String? ?? '',
      productImage: resolveImageUrl(json['productImage'] as String?),
      variantLabel: label,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.deliveryAddress,
    required super.paymentMethod,
    required super.total,
    required super.status,
    required super.createdAt,
    super.estimatedDelivery,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return OrderModel(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      total: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: orderStatusFromString(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
