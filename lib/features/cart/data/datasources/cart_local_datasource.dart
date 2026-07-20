import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCart();
  Future<void> addItem(CartItemModel item);
  Future<void> removeItem(String itemId);
  Future<void> updateQuantity(String itemId, int quantity);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final List<CartItemModel> _items = [];

  @override
  Future<List<CartItemModel>> getCart() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addItem(CartItemModel item) async {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = CartItemModel.fromEntity(
        existing.copyWith(quantity: existing.quantity + item.quantity),
      );
      AppLogger.info(
        'Cart: quantity updated for ${item.productName}',
        tag: 'CartLocalDataSource',
      );
    } else {
      _items.add(item);
      AppLogger.info(
        'Cart: added ${item.productName}',
        tag: 'CartLocalDataSource',
      );
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    _items.removeWhere((i) => i.id == itemId);
    AppLogger.info('Cart: removed item $itemId', tag: 'CartLocalDataSource');
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = CartItemModel.fromEntity(
          _items[index].copyWith(quantity: quantity),
        );
      }
    }
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
    AppLogger.info('Cart: cleared', tag: 'CartLocalDataSource');
  }
}

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>(
  (_) => CartLocalDataSourceImpl(),
);
