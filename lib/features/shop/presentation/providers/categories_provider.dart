import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';

final categoriesNotifierProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryEntity>>(
      CategoriesNotifier.new,
    );

class CategoriesNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return GetCategoriesUseCase(ref.watch(shopRepositoryProvider))(
      const NoParams(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final result = await GetCategoriesUseCase(
        ref.read(shopRepositoryProvider),
      )(const NoParams());
      state = AsyncValue.data(result);
    } catch (e, st) {
      AppLogger.error(
        'Categories refresh failed',
        tag: 'CategoriesNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
    }
  }
}

final productsNotifierProvider =
    AsyncNotifierProvider.family<
      ProductsNotifier,
      List<ProductEntity>,
      String?
    >(ProductsNotifier.new);

class ProductsNotifier extends AsyncNotifier<List<ProductEntity>> {
  ProductsNotifier(this.categoryId);

  final String? categoryId;

  // Currently applied query/filters so search, filter and refresh compose.
  String? _query;
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'newest';

  @override
  Future<List<ProductEntity>> build() async {
    final products = await GetProductsUseCase(ref.read(shopRepositoryProvider))(
      GetProductsParams(categoryId: categoryId),
    );
    return _applyClientFilters(products);
  }

  /// Applies the current price-range filter and sort to a product list.
  /// Done client-side for the mock layer; move to query params when the
  /// real API supports filtering/sorting.
  List<ProductEntity> _applyClientFilters(List<ProductEntity> products) {
    var list = products.where((p) {
      final min = _minPrice ?? 0;
      final max = _maxPrice ?? double.infinity;
      return p.basePrice >= min && p.basePrice <= max;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case 'price_desc':
        list.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popular':
        list.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return list;
  }

  Future<void> _reload() async {
    state = const AsyncValue.loading();
    try {
      // When the user searches, also try to match a category by name so that
      // typing e.g. "Grocery" surfaces products in that category even if the
      // product name/description doesn't contain the term.
      final effectiveCategoryId = categoryId ?? _matchedCategoryId();
      final result = await GetProductsUseCase(ref.read(shopRepositoryProvider))(
        GetProductsParams(categoryId: effectiveCategoryId, searchQuery: _query),
      );
      state = AsyncValue.data(_applyClientFilters(result));
    } catch (e, st) {
      AppLogger.error(
        'Products reload failed',
        tag: 'ProductsNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
    }
  }

  /// If the search text matches a category name, return that category's id so
  /// the backend filters by it. Returns null when there's no query or match.
  String? _matchedCategoryId() {
    final q = _query?.trim().toLowerCase();
    if (q == null || q.isEmpty) return null;
    final categories = ref.read(categoriesNotifierProvider).asData?.value;
    if (categories == null) return null;
    for (final c in categories) {
      final name = c.name.toLowerCase();
      if (name == q || name.contains(q) || q.contains(name)) {
        // When the term matches a category, search by category instead of
        // the free-text query (which wouldn't match product names).
        _query = null;
        return c.id;
      }
    }
    return null;
  }

  Future<void> search(String query) async {
    _query = query;
    await _reload();
  }

  Future<void> clearSearch() async {
    _query = null;
    await _reload();
  }

  /// Apply price range + sort selected in the filter sheet.
  Future<void> applyFilters({
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    if (sortBy != null) _sortBy = sortBy;
    await _reload();
  }

  /// Re-fetch from scratch, surfacing the loading state so the UI can show
  /// skeletons during pull-to-refresh. Keeps active search/filters applied.
  Future<void> refresh() async {
    await _reload();
  }
}

final productDetailProvider = FutureProvider.family<ProductEntity, String>((
  ref,
  productId,
) async {
  return GetProductDetailUseCase(ref.watch(shopRepositoryProvider))(productId);
});
