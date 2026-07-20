import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/app_logger.dart';

/// Result of validating a promo code against a cart subtotal.
class PromoValidation {
  final bool valid;
  final String code;
  final double discountPercent;
  final double discountAmount;
  final double newTotal;
  final String? message;

  const PromoValidation({
    required this.valid,
    required this.code,
    required this.discountPercent,
    required this.discountAmount,
    required this.newTotal,
    this.message,
  });

  factory PromoValidation.fromJson(Map<String, dynamic> json) {
    return PromoValidation(
      valid: json['valid'] as bool? ?? false,
      code: json['code'] as String? ?? '',
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      newTotal: (json['newTotal'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PromoRemoteDataSource {
  PromoRemoteDataSource(this._apiClient);
  final ApiClient _apiClient;

  /// POST /Promos/validate — checks a code against the cart subtotal.
  /// Returns the discount details, or a failed validation with the server's
  /// message (e.g. "Promo code expired.").
  Future<PromoValidation> validate({
    required String code,
    required double cartSubTotal,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.validatePromo,
        data: {'code': code, 'cartSubTotal': cartSubTotal},
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info('Promo validated: $code', tag: 'PromoDataSource');
      return PromoValidation.fromJson(data);
    } on DioException catch (e) {
      // The backend returns BadRequest with a message for invalid/expired codes.
      final msg =
          (e.response?.data is Map &&
              (e.response?.data as Map)['message'] is String)
          ? (e.response!.data as Map)['message'] as String
          : 'Invalid promo code.';
      return PromoValidation(
        valid: false,
        code: code,
        discountPercent: 0,
        discountAmount: 0,
        newTotal: cartSubTotal,
        message: msg,
      );
    }
  }
}

final promoRemoteDataSourceProvider = Provider<PromoRemoteDataSource>(
  (ref) => PromoRemoteDataSource(ref.watch(apiClientProvider)),
);
