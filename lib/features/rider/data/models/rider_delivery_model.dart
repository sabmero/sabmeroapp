import '../../domain/entities/rider_delivery_entity.dart';

class RiderDeliveryModel extends RiderDeliveryEntity {
  const RiderDeliveryModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.deliveryAddress,
    required super.items,
    required super.totalAmount,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.status,
    required super.createdAt,
  });

  factory RiderDeliveryModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return RiderDeliveryModel(
      id: '${json['id'] ?? ''}',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerPhone: json['customerPhone'] as String? ?? '',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      items: itemsJson
          .map(
            (e) => RiderDeliveryItemEntity(
              productName: (e as Map<String, dynamic>)['productName'] as String? ?? '',
              quantity: (e['quantity'] as num?)?.toInt() ?? 1,
            ),
          )
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      status: riderDeliveryStatusFromString(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
