import '../../../shop/domain/entities/category_entity.dart';

class CartItemEntity {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final String variantId;
  final String variantLabel;
  final String vendorId;
  final String vendorName;
  final double unitPrice;
  final int quantity;
  final String unit;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.variantId,
    required this.variantLabel,
    required this.vendorId,
    required this.vendorName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
  });

  double get subtotal => unitPrice * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImage: productImage,
      variantId: variantId,
      variantLabel: variantLabel,
      vendorId: vendorId,
      vendorName: vendorName,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      unit: unit,
    );
  }

  factory CartItemEntity.fromProduct({
    required ProductEntity product,
    required ProductVariantEntity variant,
    required int quantity,
  }) {
    return CartItemEntity(
      id: '${product.id}_${variant.id}',
      productId: product.id,
      productName: product.name,
      productImage: product.primaryImage,
      variantId: variant.id,
      variantLabel: variant.label,
      vendorId: product.vendorId,
      vendorName: product.vendorName,
      unitPrice: variant.price,
      quantity: quantity,
      unit: variant.unit,
    );
  }
}
