import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../shop/data/models/category_model.dart';
import '../models/vendor_model.dart';
import '../models/vendor_sales_summary_model.dart';

abstract class VendorRemoteDataSource {
  Future<VendorModel> registerVendor({
    required String businessName,
    required String address,
    required String phone,
  });
  Future<VendorModel> getVendorProfile();
  Future<List<ProductModel>> getVendorProducts();
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
  Future<List<OrderModel>> getVendorOrders();
  Future<VendorSalesSummaryModel> getVendorSales();
}

class VendorRemoteDataSourceImpl implements VendorRemoteDataSource {
  VendorRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // Turn a resolved absolute image URL back into the stored relative path,
  // so we don't persist the full origin twice.
  String? _toStoredPath(List<String> imageUrls) {
    if (imageUrls.isEmpty) return null;
    final url = imageUrls.first;
    if (url.startsWith(ApiConstants.serverOrigin)) {
      return url.substring(ApiConstants.serverOrigin.length);
    }
    return url;
  }

  Map<String, dynamic> _productBody(ProductModel p, {bool forUpdate = false}) {
    return {
      'name': p.name,
      'description': p.description,
      'price': p.basePrice,
      'stock': p.stock,
      'categoryId': int.tryParse(p.categoryId) ?? 0,
      if (_toStoredPath(p.imageUrls) != null)
        'imagePath': _toStoredPath(p.imageUrls),
      if (p.sizeOptions.isNotEmpty) 'sizeOptions': p.sizeOptions.join(','),
      if (p.colorOptions.isNotEmpty) 'colorOptions': p.colorOptions.join(','),
      'unit': p.unit,
      if (forUpdate) 'isActive': p.isAvailable,
    };
  }

  @override
  Future<VendorModel> registerVendor({
    required String businessName,
    required String address,
    required String phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.vendorApply,
        data: {'businessName': businessName, 'businessAddress': address},
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info(
        'Vendor applied: ${data['id']}',
        tag: 'VendorRemoteDataSource',
      );
      return VendorModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<VendorModel> getVendorProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.vendorMe);
      final data = _apiClient.unwrapObject(response.data);
      return VendorModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<ProductModel>> getVendorProducts() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.myProducts);
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.products,
        data: _productBody(product),
      );
      final data = _apiClient.unwrapObject(response.data);
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.products}/${product.id}',
        data: _productBody(product, forUpdate: true),
      );
      final data = _apiClient.unwrapObject(response.data);
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.products}/$productId',
      );
      _apiClient.unwrapMessage(response.data);
      AppLogger.info(
        'Product deleted: $productId',
        tag: 'VendorRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<OrderModel>> getVendorOrders() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.vendorOrders);
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<VendorSalesSummaryModel> getVendorSales() async {
    // No sales endpoint exists; derive the summary from orders + products.
    final orders = await getVendorOrders();
    final products = await getVendorProducts();
    double commissionRate = 0.10;
    try {
      final profile = await getVendorProfile();
      commissionRate = profile.commissionRate > 0
          ? profile.commissionRate / 100
          : commissionRate;
    } catch (_) {
      // fall back to default commission if profile fetch fails
    }
    return VendorSalesSummaryModel.fromOrders(
      orders: orders,
      totalProducts: products.length,
      commissionRate: commissionRate,
    );
  }
}

final vendorRemoteDataSourceProvider = Provider<VendorRemoteDataSource>(
  (ref) => VendorRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
