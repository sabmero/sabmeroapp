import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  const OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrderEntity> placeOrder({
    required List<CartItemEntity> items,
    required String address,
    required String paymentMethod,
    required double total,
    String? promoCode,
    String? paymentScreenshotPath,
  }) async {
    try {
      // `total` is intentionally not sent; the server computes it.
      return await remoteDataSource.placeOrder(
        items: items,
        address: address,
        paymentMethod: paymentMethod,
        promoCode: promoCode,
        paymentScreenshotPath: paymentScreenshotPath,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String> uploadPaymentScreenshot(String filePath) async {
    try {
      return await remoteDataSource.uploadPaymentScreenshot(filePath);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<OrderEntity>> getOrders() async {
    try {
      final orders = await remoteDataSource.getOrders();
      return List<OrderEntity>.from(orders);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<OrderEntity> getOrderDetail(String orderId) async {
    try {
      return await remoteDataSource.getOrderDetail(orderId);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<OrderEntity> trackOrder(String orderId) => getOrderDetail(orderId);

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderRemoteDataSourceProvider));
});
