import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_info_entitiy.dart';

enum PaymentMethodType { cashOnDelivery, qrPay }

class PaymentState {
  final PaymentMethodType selectedMethod;
  final String? lastScannedCode;
  final bool isProcessing;
  final PaymentInfoEntity? paymentInfo;
  final String? error;

  const PaymentState({
    this.selectedMethod = PaymentMethodType.cashOnDelivery,
    this.lastScannedCode,
    this.isProcessing = false,
    this.paymentInfo,
    this.error,
  });

  PaymentState copyWith({
    PaymentMethodType? selectedMethod,
    String? lastScannedCode,
    bool? isProcessing,
    PaymentInfoEntity? paymentInfo,
    String? error,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      lastScannedCode: lastScannedCode ?? this.lastScannedCode,
      isProcessing: isProcessing ?? this.isProcessing,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      error: error,
    );
  }
}

final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);

class PaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => const PaymentState();

  void selectMethod(PaymentMethodType method) {
    state = state.copyWith(selectedMethod: method);
    AppLogger.info('Payment method selected: $method', tag: 'PaymentNotifier');
  }

  // Fetch the QR image + instructions to show the user.
  Future<PaymentInfoEntity?> loadQr() async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final info = await ref.read(paymentRepositoryProvider).getQr();
      state = state.copyWith(isProcessing: false, paymentInfo: info);
      AppLogger.info('Payment QR loaded', tag: 'PaymentNotifier');
      return info;
    } catch (e, st) {
      AppLogger.error('Load QR failed',
          tag: 'PaymentNotifier', error: e, stackTrace: st);
      state = state.copyWith(isProcessing: false, error: e.toString());
      return null;
    }
  }

  // Submit a payment screenshot for an order or booking.
  //  type: "Order" | "Booking"
  Future<bool> submitPayment({
    required String type,
    required int id,
    required String screenshotPath,
  }) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      await ref.read(paymentRepositoryProvider).submit(
            type: type,
            id: id,
            screenshotPath: screenshotPath,
          );
      state = state.copyWith(isProcessing: false);
      AppLogger.info('Payment submitted for $type #$id', tag: 'PaymentNotifier');
      return true;
    } catch (e, st) {
      AppLogger.error('Submit payment failed',
          tag: 'PaymentNotifier', error: e, stackTrace: st);
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }

  void recordScannedCode(String code) {
    state = state.copyWith(lastScannedCode: code);
    AppLogger.info('QR scanned: $code', tag: 'PaymentNotifier');
  }

  void reset() => state = const PaymentState();
}
