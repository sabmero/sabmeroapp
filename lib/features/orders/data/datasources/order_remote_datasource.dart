import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> placeOrder({
    required List<CartItemEntity> items,
    required String address,
    required String paymentMethod,
    String? promoCode,
    String? paymentScreenshotPath,
  });
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderDetail(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<String> uploadPaymentScreenshot(String filePath);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // The backend takes a payment method of "COD" | "QR". The app stores it
  // lowercased ("cod"/"qr"), so normalise on the way out.
  String _normalisePayment(String method) {
    final m = method.toUpperCase();
    return m == 'QR' ? 'QR' : 'COD';
  }

  // A variant label like "M / Black" is split back into size + colour for the API.
  Map<String, String?> _splitVariant(String label) {
    if (label.trim().isEmpty) return {'size': null, 'color': null};
    final parts = label.split('/').map((e) => e.trim()).toList();
    if (parts.length >= 2) return {'size': parts[0], 'color': parts[1]};
    return {'size': parts[0], 'color': null};
  }

  @override
  Future<OrderModel> placeOrder({
    required List<CartItemEntity> items,
    required String address,
    required String paymentMethod,
    String? promoCode,
    String? paymentScreenshotPath,
  }) async {
    try {
      final body = {
        'deliveryAddress': address,
        'paymentMethod': _normalisePayment(paymentMethod),
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        if (paymentScreenshotPath != null && paymentScreenshotPath.isNotEmpty)
          'paymentScreenshotPath': paymentScreenshotPath,
        'items': items.map((i) {
          final v = _splitVariant(i.variantLabel);
          return {
            'productId': int.tryParse(i.productId) ?? 0,
            'quantity': i.quantity,
            if (v['size'] != null) 'selectedSize': v['size'],
            if (v['color'] != null) 'selectedColor': v['color'],
          };
        }).toList(),
      };
      final response = await _apiClient.dio.post(
        ApiConstants.orders,
        data: body,
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info(
        'Order placed: ${data['id']}',
        tag: 'OrderRemoteDataSource',
      );
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> uploadPaymentScreenshot(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadPayment,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      final path = data['path'] as String? ?? '';
      AppLogger.info(
        'Order payment screenshot uploaded: $path',
        tag: 'OrderRemoteDataSource',
      );
      return path;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.myOrders);
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<OrderModel> getOrderDetail(String orderId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.orders}/$orderId',
      );
      final data = _apiClient.unwrapObject(response.data);
      return OrderModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.orders}/$orderId/cancel',
      );
      _apiClient.unwrapMessage(response.data);
      AppLogger.info('Order cancelled: $orderId', tag: 'OrderRemoteDataSource');
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>(
  (ref) => OrderRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
