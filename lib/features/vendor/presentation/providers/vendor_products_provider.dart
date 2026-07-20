import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/usecases/register_vendor_usecase.dart';

final vendorProductsNotifierProvider =
    AsyncNotifierProvider<VendorProductsNotifier, List<ProductEntity>>(
  VendorProductsNotifier.new,
);

class VendorProductsNotifier extends AsyncNotifier<List<ProductEntity>> {
  @override
  Future<List<ProductEntity>> build() async {
    return GetVendorProductsUseCase(ref.watch(vendorRepositoryProvider))(
      const NoParams(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final products = await GetVendorProductsUseCase(
        ref.read(vendorRepositoryProvider),
      )(const NoParams());
      state = AsyncValue.data(products);
    } catch (e, st) {
      AppLogger.error(
        'Vendor products refresh failed',
        tag: 'VendorProductsNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createProduct(ProductEntity product) async {
    try {
      final created = await CreateProductUseCase(
        ref.read(vendorRepositoryProvider),
      )(product);
      final current = state.asData?.value ?? [];
      state = AsyncValue.data([created, ...current]);
      AppLogger.info('Vendor product created: ${created.name}', tag: 'VendorProductsNotifier');
    } catch (e, st) {
      AppLogger.error(
        'Create product failed',
        tag: 'VendorProductsNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> updateProduct(ProductEntity product) async {
    try {
      final updated = await UpdateProductUseCase(
        ref.read(vendorRepositoryProvider),
      )(product);
      final current = state.asData?.value ?? [];
      state = AsyncValue.data([
        for (final p in current) p.id == updated.id ? updated : p,
      ]);
      AppLogger.info('Vendor product updated: ${updated.name}', tag: 'VendorProductsNotifier');
    } catch (e, st) {
      AppLogger.error(
        'Update product failed',
        tag: 'VendorProductsNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await DeleteProductUseCase(ref.read(vendorRepositoryProvider))(productId);
      final current = state.asData?.value ?? [];
      state = AsyncValue.data(
        current.where((p) => p.id != productId).toList(),
      );
      AppLogger.info('Vendor product deleted: $productId', tag: 'VendorProductsNotifier');
    } catch (e, st) {
      AppLogger.error(
        'Delete product failed',
        tag: 'VendorProductsNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
