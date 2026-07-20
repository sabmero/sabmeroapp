import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productImage,
    required super.variantId,
    required super.variantLabel,
    required super.vendorId,
    required super.vendorName,
    required super.unitPrice,
    required super.quantity,
    required super.unit,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String,
      variantId: json['variant_id'] as String,
      variantLabel: json['variant_label'] as String,
      vendorId: json['vendor_id'] as String,
      vendorName: json['vendor_name'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'product_image': productImage,
        'variant_id': variantId,
        'variant_label': variantLabel,
        'vendor_id': vendorId,
        'vendor_name': vendorName,
        'unit_price': unitPrice,
        'quantity': quantity,
        'unit': unit,
      };

  factory CartItemModel.fromEntity(CartItemEntity entity) => CartItemModel(
        id: entity.id,
        productId: entity.productId,
        productName: entity.productName,
        productImage: entity.productImage,
        variantId: entity.variantId,
        variantLabel: entity.variantLabel,
        vendorId: entity.vendorId,
        vendorName: entity.vendorName,
        unitPrice: entity.unitPrice,
        quantity: entity.quantity,
        unit: entity.unit,
      );
}
