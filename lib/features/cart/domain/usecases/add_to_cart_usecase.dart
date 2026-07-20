import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase implements UseCase<List<CartItemEntity>, NoParams> {
  final CartRepository repository;
  const GetCartUseCase(this.repository);

  @override
  Future<List<CartItemEntity>> call(NoParams params) => repository.getCart();
}

class AddToCartUseCase implements UseCase<void, CartItemEntity> {
  final CartRepository repository;
  const AddToCartUseCase(this.repository);

  @override
  Future<void> call(CartItemEntity item) => repository.addItem(item);
}

class RemoveFromCartParams {
  final String itemId;
  const RemoveFromCartParams(this.itemId);
}

class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;
  const RemoveFromCartUseCase(this.repository);

  @override
  Future<void> call(RemoveFromCartParams params) =>
      repository.removeItem(params.itemId);
}

class UpdateQuantityParams {
  final String itemId;
  final int quantity;
  const UpdateQuantityParams({required this.itemId, required this.quantity});
}

class UpdateQuantityUseCase implements UseCase<void, UpdateQuantityParams> {
  final CartRepository repository;
  const UpdateQuantityUseCase(this.repository);

  @override
  Future<void> call(UpdateQuantityParams params) =>
      repository.updateQuantity(params.itemId, params.quantity);
}

class ClearCartUseCase implements UseCase<void, NoParams> {
  final CartRepository repository;
  const ClearCartUseCase(this.repository);

  @override
  Future<void> call(NoParams params) => repository.clearCart();
}
