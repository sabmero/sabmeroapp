import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/category_model.dart';

abstract class ShopRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  });
  Future<ProductModel> getProductDetail(String productId);
  Future<List<ProductModel>> searchProducts(String query);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  ShopRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.categories);
      final list = _apiClient.unwrapList(response.data);
      AppLogger.info(
        'Categories loaded: ${list.length}',
        tag: 'ShopRemoteDataSource',
      );
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search': searchQuery,
        if (categoryId != null && categoryId.isNotEmpty)
          'categoryId': int.tryParse(categoryId),
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      }..removeWhere((_, v) => v == null);

      final response = await _apiClient.dio.get(
        ApiConstants.products,
        queryParameters: query,
      );
      final list = _apiClient.unwrapList(response.data);
      AppLogger.info(
        'Products loaded: ${list.length}',
        tag: 'ShopRemoteDataSource',
      );
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<ProductModel> getProductDetail(String productId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.products}/$productId',
      );
      final data = _apiClient.unwrapObject(response.data);
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) {
    return getProducts(searchQuery: query);
  }
}

final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>(
  (ref) => ShopRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
