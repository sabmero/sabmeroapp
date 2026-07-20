import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderEntity>>(
      OrdersNotifier.new,
    );

class OrdersNotifier extends AsyncNotifier<List<OrderEntity>> {
  @override
  Future<List<OrderEntity>> build() async {
    return GetOrdersUseCase(ref.watch(orderRepositoryProvider))(
      const NoParams(),
    );
  }

  Future<({bool success, String message, OrderEntity? order})> placeOrder({
    required List<CartItemEntity> items,
    required String address,
    required String paymentMethod,
    required double total,
    String? promoCode,
    String? paymentScreenshotLocalPath,
  }) async {
    try {
      final repository = ref.read(orderRepositoryProvider);

      // QR orders upload the proof screenshot first.
      String? screenshotServerPath;
      if (paymentMethod.toUpperCase() == 'QR' &&
          paymentScreenshotLocalPath != null &&
          paymentScreenshotLocalPath.isNotEmpty) {
        screenshotServerPath = await UploadOrderPaymentScreenshotUseCase(
          repository,
        )(paymentScreenshotLocalPath);
      }

      final order = await PlaceOrderUseCase(repository)(
        PlaceOrderParams(
          items: items,
          address: address,
          paymentMethod: paymentMethod,
          total: total,
          promoCode: promoCode,
          paymentScreenshotPath: screenshotServerPath,
        ),
      );
      final current = state.asData?.value ?? [];
      state = AsyncValue.data([order, ...current]);
      AppLogger.info('Order placed: ${order.id}', tag: 'OrdersNotifier');
      return (success: true, message: 'Order placed.', order: order);
    } catch (e, st) {
      AppLogger.error(
        'Place order failed',
        tag: 'OrdersNotifier',
        error: e,
        stackTrace: st,
      );
      return (success: false, message: _readableError(e), order: null);
    }
  }

  String _readableError(Object e) => e
      .toString()
      .replaceFirst('ServerFailure: ', '')
      .replaceFirst('AuthFailure: ', '')
      .replaceFirst('NetworkFailure: ', '')
      .replaceFirst('Exception: ', '');

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final orders = await GetOrdersUseCase(ref.read(orderRepositoryProvider))(
        const NoParams(),
      );
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final orderDetailProvider = FutureProvider.family<OrderEntity, String>((
  ref,
  orderId,
) async {
  return GetOrderDetailUseCase(ref.watch(orderRepositoryProvider))(orderId);
});
