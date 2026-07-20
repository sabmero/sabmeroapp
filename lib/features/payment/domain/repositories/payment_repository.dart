import '../entities/payment_info_entitiy.dart';

abstract class PaymentRepository {
  Future<PaymentInfoEntity> getQr();
  Future<void> submit({
    required String type,
    required int id,
    required String screenshotPath,
  });
}
