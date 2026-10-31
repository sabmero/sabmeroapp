import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../models/service_catalog_models.dart';

/// Reads the admin-managed service catalog. These endpoints are public.
class ServiceCatalogRemoteDataSource {
  ServiceCatalogRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ServiceCategoryItem>> fetchCategories() async {
    try {
      final response = await _apiClient.dio.get('/ServiceCategories');
      final list = _apiClient.unwrapList(response.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ServiceCategoryItem.fromJson)
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  Future<List<ServiceOffer>> fetchServices() async {
    try {
      final response = await _apiClient.dio.get('/services');
      final list = _apiClient.unwrapList(response.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ServiceOffer.fromService)
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  Future<List<ServiceOffer>> fetchPackages() async {
    try {
      final response = await _apiClient.dio.get('/ServicePackages');
      final list = _apiClient.unwrapList(response.data);
      return list
          .whereType<Map<String, dynamic>>()
          .map(ServiceOffer.fromPackage)
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final serviceCatalogDataSourceProvider = Provider<ServiceCatalogRemoteDataSource>(
  (ref) => ServiceCatalogRemoteDataSource(ref.watch(apiClientProvider)),
);
