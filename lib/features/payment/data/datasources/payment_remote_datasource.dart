import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/payment_info_model.dart';

abstract class PaymentRemoteDataSource {
  /// Fetch the admin's payment QR + instructions.
  Future<PaymentInfoModel> getQr();

  /// Submit a payment screenshot for an Order or Booking.
  /// [type] is "Order" or "Booking"; [id] is that record's id.
  Future<void> submit({
    required String type,
    required int id,
    required String screenshotPath,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PaymentInfoModel> getQr() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.paymentQr);
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info('Fetched payment QR', tag: 'PaymentDataSource');
      return PaymentInfoModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> submit({
    required String type,
    required int id,
    required String screenshotPath,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.paymentSubmit,
        data: {
          'type': type,
          'id': id,
          'screenshotPath': screenshotPath,
        },
      );
      _apiClient.unwrapMessage(response.data);
      AppLogger.info(
        'Payment screenshot submitted for $type #$id',
        tag: 'PaymentDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
