import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';

class CartState {
  final List<CartItemEntity> items;

  const CartState({required this.items});

  const CartState.empty() : this(items: const []);

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}

final cartNotifierProvider =
    NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    _loadCart();
    return const CartState.empty();
  }

  Future<void> _loadCart() async {
    try {
      final items = await GetCartUseCase(ref.read(cartRepositoryProvider))(
        const NoParams(),
      );
      state = CartState(items: items);
    } catch (e, st) {
      AppLogger.error(
        'Failed to load cart',
        tag: 'CartNotifier',
        error: e,
        stackTrace: st,
      );
    }
  }

  void addItem({
    required ProductEntity product,
    required ProductVariantEntity variant,
    required int quantity,
  }) {
    final item = CartItemEntity.fromProduct(
      product: product,
      variant: variant,
      quantity: quantity,
    );

    final existing = state.items.indexWhere((i) => i.id == item.id);
    List<CartItemEntity> updated;
    if (existing >= 0) {
      updated = List.from(state.items);
      updated[existing] = updated[existing]
          .copyWith(quantity: updated[existing].quantity + quantity);
    } else {
      updated = [...state.items, item];
    }

    state = CartState(items: updated);
    AddToCartUseCase(ref.read(cartRepositoryProvider))(item);
    AppLogger.info('Added to cart: ${product.name}', tag: 'CartNotifier');
  }

  void removeItem(String itemId) {
    state = CartState(
      items: state.items.where((i) => i.id != itemId).toList(),
    );
    RemoveFromCartUseCase(ref.read(cartRepositoryProvider))(
      RemoveFromCartParams(itemId),
    );
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    state = CartState(
      items: state.items.map((i) {
        return i.id == itemId ? i.copyWith(quantity: quantity) : i;
      }).toList(),
    );
    UpdateQuantityUseCase(ref.read(cartRepositoryProvider))(
      UpdateQuantityParams(itemId: itemId, quantity: quantity),
    );
  }

  void clearCart() {
    state = const CartState.empty();
    ClearCartUseCase(ref.read(cartRepositoryProvider))(const NoParams());
  }
}
