class CategoryEntity {
  final String id;
  final String name;
  final String imageUrl;
  final int productCount;
  final bool isActive;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.productCount = 0,
    this.isActive = true,
  });
}

class ProductVariantEntity {
  final String id;
  final String label;
  final double price;
  final int stock;
  final String unit;

  const ProductVariantEntity({
    required this.id,
    required this.label,
    required this.price,
    required this.stock,
    required this.unit,
  });

  bool get isInStock => stock > 0;
}

class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final String vendorId;
  final String vendorName;
  final List<String> imageUrls;
  final List<ProductVariantEntity> variants;
  final List<String> sizeOptions;
  final List<String> colorOptions;
  final double basePrice;
  final int stock;
  final String unit;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.vendorId,
    required this.vendorName,
    required this.imageUrls,
    required this.variants,
    this.sizeOptions = const [],
    this.colorOptions = const [],
    required this.basePrice,
    this.stock = 0,
    this.unit = 'pcs',
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.createdAt,
  });

  String get primaryImage => imageUrls.isNotEmpty
      ? imageUrls.first
      : 'https://picsum.photos/seed/$id/400/400';

  ProductVariantEntity? get defaultVariant =>
      variants.isNotEmpty ? variants.first : null;
}
