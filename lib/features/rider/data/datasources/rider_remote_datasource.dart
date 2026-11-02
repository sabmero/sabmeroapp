import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/rider_delivery_entity.dart';
import '../models/rider_delivery_model.dart';

String riderDeliveryStatusToApiString(RiderDeliveryStatus status) =>
    switch (status) {
      RiderDeliveryStatus.dispatched => 'Dispatched',
      RiderDeliveryStatus.delivered => 'Delivered',
      RiderDeliveryStatus.cancelled => 'Cancelled',
    };

abstract class RiderRemoteDataSource {
  Future<List<RiderDeliveryModel>> getMyDeliveries();
  Future<void> updateDeliveryStatus(
    String orderId,
    RiderDeliveryStatus status, {
    String? collectionMethod,
    String? amountInWords,
    String? collectionScreenshotPath,
  });

  /// Uploads an online-payment screenshot and returns its server path.
  Future<String> uploadPaymentProof(String filePath);
}

class RiderRemoteDataSourceImpl implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<RiderDeliveryModel>> getMyDeliveries() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.riderOrders);
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => RiderDeliveryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> updateDeliveryStatus(
    String orderId,
    RiderDeliveryStatus status, {
    String? collectionMethod,
    String? amountInWords,
    String? collectionScreenshotPath,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.orders}/$orderId/status',
        data: {
          'status': riderDeliveryStatusToApiString(status),
          if (collectionMethod != null) 'collectionMethod': collectionMethod,
          if (amountInWords != null && amountInWords.isNotEmpty)
            'amountInWords': amountInWords,
          if (collectionScreenshotPath != null)
            'collectionScreenshotPath': collectionScreenshotPath,
        },
      );
      _apiClient.unwrapMessage(response.data);
      AppLogger.info(
        'Delivery $orderId status -> ${riderDeliveryStatusToApiString(status)}',
        tag: 'RiderRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> uploadPaymentProof(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadPayment,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      return data['path'] as String? ?? '';
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final riderRemoteDataSourceProvider = Provider<RiderRemoteDataSource>(
  (ref) => RiderRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
