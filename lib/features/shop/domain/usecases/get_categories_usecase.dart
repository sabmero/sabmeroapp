import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/shop_repository.dart';

class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  final ShopRepository repository;
  const GetCategoriesUseCase(this.repository);

  @override
  Future<List<CategoryEntity>> call(NoParams params) =>
      repository.getCategories();
}

class GetProductsParams {
  final String? categoryId;
  final String? searchQuery;
  final int page;
  final int pageSize;

  const GetProductsParams({
    this.categoryId,
    this.searchQuery,
    this.page = 1,
    this.pageSize = 20,
  });
}

class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  final ShopRepository repository;
  const GetProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(GetProductsParams params) =>
      repository.getProducts(
        categoryId: params.categoryId,
        searchQuery: params.searchQuery,
        page: params.page,
        pageSize: params.pageSize,
      );
}

class GetProductDetailUseCase implements UseCase<ProductEntity, String> {
  final ShopRepository repository;
  const GetProductDetailUseCase(this.repository);

  @override
  Future<ProductEntity> call(String productId) =>
      repository.getProductDetail(productId);
}

class SearchProductsUseCase
    implements UseCase<List<ProductEntity>, String> {
  final ShopRepository repository;
  const SearchProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(String query) =>
      repository.searchProducts(query);
}
