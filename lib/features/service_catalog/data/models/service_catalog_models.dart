import '../../../../core/constants/api_constants.dart';

double _d(dynamic v) =>
    v is num ? v.toDouble() : (double.tryParse('${v ?? ''}') ?? 0);

int _i(dynamic v) => v is num ? v.toInt() : (int.tryParse('${v ?? ''}') ?? 0);

String? _text(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

/// Full image URL for a path returned by the API ('' when there is no image).
String serviceImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${ApiConstants.serverOrigin}${path.startsWith('/') ? '' : '/'}$path';
}

/// A service category from GET /api/ServiceCategories. Main categories
/// (parentId == null) carry their sub-categories in [children].
class ServiceCategoryItem {
  const ServiceCategoryItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.parentId,
    required this.sortOrder,
    required this.children,
  });

  final int id;
  final String name;
  final String imageUrl;
  final int? parentId;
  final int sortOrder;
  final List<ServiceCategoryItem> children;

  /// This category's id plus the ids of its sub-categories.
  List<int> get allIds => [id, ...children.map((c) => c.id)];

  factory ServiceCategoryItem.fromJson(Map<String, dynamic> j) {
    final kids =
        ((j['children'] as List?) ?? [])
            .whereType<Map<String, dynamic>>()
            .where((c) => c['isActive'] != false)
            .map(ServiceCategoryItem.fromJson)
            .toList()
          ..sort(_byOrder);
    return ServiceCategoryItem(
      id: _i(j['id']),
      name: (j['name'] ?? '').toString(),
      imageUrl: serviceImageUrl(j['imagePath']?.toString()),
      parentId: j['parentId'] == null ? null : _i(j['parentId']),
      sortOrder: _i(j['sortOrder']),
      children: kids,
    );
  }

  static int _byOrder(ServiceCategoryItem a, ServiceCategoryItem b) {
    final c = a.sortOrder.compareTo(b.sortOrder);
    return c != 0 ? c : a.name.compareTo(b.name);
  }
}

/// Something a customer can book: a catalog service (GET /api/services) or a
/// service package (GET /api/ServicePackages).
class ServiceOffer {
  const ServiceOffer({
    required this.key,
    required this.isPackage,
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.categoryId,
    required this.includes,
    this.imageUrls = const [],
    this.durationText,
    this.warranty,
    this.homeServiceAvailable = true,
    this.requirements,
    this.isFeatured = false,
  });

  final String key;
  final bool isPackage;
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double? oldPrice;
  final int discountPercent;
  final int? categoryId;
  final List<String> includes;

  // Details only catalog services have (packages leave them empty).
  final List<String> imageUrls; // gallery, first = main image
  final String? durationText;
  final String? warranty;
  final bool homeServiceAvailable;
  final String? requirements;
  final bool isFeatured;

  /// Gallery to show: the gallery images, or the single main image.
  List<String> get gallery =>
      imageUrls.isNotEmpty ? imageUrls : (imageUrl.isEmpty ? const [] : [imageUrl]);

  bool get hasPrice => price > 0;
  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// Arguments for the existing booking screen. The name becomes the
  /// booking's service type.
  Map<String, dynamic> get bookingArgs => {
    'categoryId': key,
    'categoryName': name,
    'estimatedCharge': price,
  };

  factory ServiceOffer.fromService(Map<String, dynamic> j) => ServiceOffer(
    key: 'svc_${_i(j['id'])}',
    isPackage: false,
    id: _i(j['id']),
    name: (j['name'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    imageUrl: serviceImageUrl(j['imagePath']?.toString()),
    price: _d(j['charge']),
    oldPrice: j['oldPrice'] == null ? null : _d(j['oldPrice']),
    discountPercent: _i(j['discountPercent']),
    categoryId: j['categoryId'] == null ? null : _i(j['categoryId']),
    includes: const [],
    imageUrls: ((j['imagePaths'] as List?) ?? [])
        .map((e) => serviceImageUrl(e.toString()))
        .where((e) => e.isNotEmpty)
        .toList(),
    durationText: _text(j['durationText']),
    warranty: _text(j['warranty']),
    homeServiceAvailable: j['homeServiceAvailable'] != false,
    requirements: _text(j['requirements']),
    isFeatured: j['isFeatured'] == true,
  );

  factory ServiceOffer.fromPackage(Map<String, dynamic> j) => ServiceOffer(
    key: 'pkg_${_i(j['id'])}',
    isPackage: true,
    id: _i(j['id']),
    name: (j['name'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    imageUrl: serviceImageUrl(j['imagePath']?.toString()),
    price: _d(j['price']),
    oldPrice: j['oldPrice'] == null ? null : _d(j['oldPrice']),
    discountPercent: _i(j['discountPercent']),
    categoryId: j['categoryId'] == null ? null : _i(j['categoryId']),
    includes: ((j['items'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map((it) {
          final n = (it['name'] ?? '').toString();
          final q = _i(it['quantity']);
          return q > 1 ? '$n × $q' : n;
        })
        .where((s) => s.isNotEmpty)
        .toList(),
  );
}
