import '../entities/category_entity.dart';

abstract class ShopRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  });
  Future<ProductEntity> getProductDetail(String productId);
  Future<List<ProductEntity>> searchProducts(String query);
}
