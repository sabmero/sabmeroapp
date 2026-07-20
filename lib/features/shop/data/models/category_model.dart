import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/category_entity.dart';

// Resolves a server-relative path like "/uploads/products/x.jpg" into a full URL.
// Leaves already-absolute http(s) URLs untouched. Returns '' for null/empty.
String resolveImageUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  final p = path.trim();
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  return '${ApiConstants.serverOrigin}${p.startsWith('/') ? '' : '/'}$p';
}

// SizeOptions/ColorOptions arrive as either a JSON array string (["S","M"])
// or a plain comma-separated string. This handles both, plus null/empty.
List<String> parseOptions(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final value = raw.trim();
  if (value.startsWith('[')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {
      // fall through to comma split
    }
  }
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    super.productCount,
    super.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      imageUrl: resolveImageUrl(json['imagePath'] as String?),
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    required super.label,
    required super.price,
    required super.stock,
    required super.unit,
  });
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.categoryName,
    required super.vendorId,
    required super.vendorName,
    required super.imageUrls,
    required super.variants,
    super.sizeOptions,
    super.colorOptions,
    required super.basePrice,
    super.stock,
    super.unit,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final sizes = parseOptions(json['sizeOptions'] as String?);
    final colors = parseOptions(json['colorOptions'] as String?);
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final stock = (json['stock'] as num?)?.toInt() ?? 0;
    final unit = json['unit'] as String? ?? 'pcs';
    final image = resolveImageUrl(json['imagePath'] as String?);

    // Multi-image gallery from the backend ("imagePaths", cover first).
    // Falls back to the single cover for older records.
    final galleryPaths = (json['imagePaths'] is List)
        ? (json['imagePaths'] as List).whereType<String>().toList()
        : const <String>[];
    final gallery = galleryPaths
        .map(resolveImageUrl)
        .where((u) => u.isNotEmpty)
        .toList();

    // The backend has no per-variant rows; it exposes size/color option lists.
    // Build display variants from the cartesian-ish combination so the existing
    // variant_selector UI keeps working. Price/stock/unit are shared.
    final variants = _buildVariants(sizes, colors, price, stock, unit);

    return ProductModel(
      id: '${json['id'] ?? ''}',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: '${json['categoryId'] ?? ''}',
      categoryName: json['categoryName'] as String? ?? '',
      vendorId: '${json['vendorId'] ?? ''}',
      vendorName: json['vendorName'] as String? ?? '',
      imageUrls: gallery.isNotEmpty
          ? gallery
          : (image.isEmpty ? const [] : [image]),
      variants: variants,
      sizeOptions: sizes,
      colorOptions: colors,
      basePrice: price,
      stock: stock,
      unit: unit,
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isAvailable: (json['isActive'] as bool? ?? true) && stock > 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static List<ProductVariantModel> _buildVariants(
    List<String> sizes,
    List<String> colors,
    double price,
    int stock,
    String unit,
  ) {
    // Products with no size/colour options still need a single purchasable
    // variant so the cart and the "Add to Cart" button work. Without this the
    // detail screen treats them as out of stock even when stock > 0.
    if (sizes.isEmpty && colors.isEmpty) {
      return [
        ProductVariantModel(
          id: 'default',
          label: '',
          price: price,
          stock: stock,
          unit: unit,
        ),
      ];
    }
    final labels = <String>[];
    if (sizes.isNotEmpty && colors.isNotEmpty) {
      for (final s in sizes) {
        for (final c in colors) {
          labels.add('$s / $c');
        }
      }
    } else {
      labels.addAll(sizes.isNotEmpty ? sizes : colors);
    }
    return [
      for (var i = 0; i < labels.length; i++)
        ProductVariantModel(
          id: 'v$i',
          label: labels[i],
          price: price,
          stock: stock,
          unit: unit,
        ),
    ];
  }
}
