import '../../domain/entities/payment_info_entitiy.dart';

class PaymentInfoModel extends PaymentInfoEntity {
  const PaymentInfoModel({
    required super.qrImagePath,
    required super.instructions,
  });

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      qrImagePath: json['qrImagePath'] as String?,
      instructions: json['instructions'] as String? ??
          'Scan this QR, pay the amount, then upload a screenshot of the payment.',
    );
  }
}
