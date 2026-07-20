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
  Future<void> updateDeliveryStatus(String orderId, RiderDeliveryStatus status);
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
    RiderDeliveryStatus status,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '${ApiConstants.orders}/$orderId/status',
        data: {'status': riderDeliveryStatusToApiString(status)},
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
}

final riderRemoteDataSourceProvider = Provider<RiderRemoteDataSource>(
  (ref) => RiderRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
