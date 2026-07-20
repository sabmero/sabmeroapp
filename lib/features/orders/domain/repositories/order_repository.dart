import '../entities/order_entity.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

abstract class OrderRepository {
  // `total` is accepted for the UI's optimistic display only; the server
  // authoritatively recomputes the order total from product prices + promo.
  Future<OrderEntity> placeOrder({
    required List<CartItemEntity> items,
    required String address,
    required String paymentMethod,
    required double total,
    String? promoCode,
    String? paymentScreenshotPath,
  });
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> getOrderDetail(String orderId);
  Future<OrderEntity> trackOrder(String orderId);
  Future<void> cancelOrder(String orderId);
  Future<String> uploadPaymentScreenshot(String filePath);
}

class PlaceOrderParams {
  final List<CartItemEntity> items;
  final String address;
  final String paymentMethod;
  final double total;
  final String? promoCode;
  final String? paymentScreenshotPath;
  const PlaceOrderParams({
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.total,
    this.promoCode,
    this.paymentScreenshotPath,
  });
}

class PlaceOrderUseCase implements UseCase<OrderEntity, PlaceOrderParams> {
  final OrderRepository repository;
  const PlaceOrderUseCase(this.repository);
  @override
  Future<OrderEntity> call(PlaceOrderParams params) => repository.placeOrder(
    items: params.items,
    address: params.address,
    paymentMethod: params.paymentMethod,
    total: params.total,
    promoCode: params.promoCode,
    paymentScreenshotPath: params.paymentScreenshotPath,
  );
}

class UploadOrderPaymentScreenshotUseCase implements UseCase<String, String> {
  final OrderRepository repository;
  const UploadOrderPaymentScreenshotUseCase(this.repository);
  @override
  Future<String> call(String filePath) =>
      repository.uploadPaymentScreenshot(filePath);
}

class GetOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;
  const GetOrdersUseCase(this.repository);
  @override
  Future<List<OrderEntity>> call(NoParams params) => repository.getOrders();
}

class GetOrderDetailUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;
  const GetOrderDetailUseCase(this.repository);
  @override
  Future<OrderEntity> call(String orderId) =>
      repository.getOrderDetail(orderId);
}

class TrackOrderUseCase implements UseCase<OrderEntity, String> {
  final OrderRepository repository;
  const TrackOrderUseCase(this.repository);
  @override
  Future<OrderEntity> call(String orderId) => repository.trackOrder(orderId);
}

class CancelOrderUseCase implements UseCase<void, String> {
  final OrderRepository repository;
  const CancelOrderUseCase(this.repository);
  @override
  Future<void> call(String orderId) => repository.cancelOrder(orderId);
}
