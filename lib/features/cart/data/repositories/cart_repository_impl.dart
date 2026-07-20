import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  const CartRepositoryImpl(this.localDataSource);

  @override
  Future<List<CartItemEntity>> getCart() async {
    try {
      return await localDataSource.getCart();
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<void> addItem(CartItemEntity item) async {
    try {
      await localDataSource.addItem(CartItemModel.fromEntity(item));
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    try {
      await localDataSource.removeItem(itemId);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await localDataSource.updateQuantity(itemId, quantity);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await localDataSource.clearCart();
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartLocalDataSourceProvider));
});
