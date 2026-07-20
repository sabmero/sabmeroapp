import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;
  const ShopRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return List<CategoryEntity>.from(categories);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<ProductEntity>> getProducts({
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
        page: page,
        pageSize: pageSize,
      );
      return List<ProductEntity>.from(products);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<ProductEntity> getProductDetail(String productId) async {
    try {
      return await remoteDataSource.getProductDetail(productId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final products = await remoteDataSource.searchProducts(query);
      return List<ProductEntity>.from(products);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepositoryImpl(ref.watch(shopRemoteDataSourceProvider));
});
