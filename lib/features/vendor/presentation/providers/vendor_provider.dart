import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/vendor_repository_impl.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/entities/vendor_sales_summary_entity.dart';
import '../../domain/usecases/register_vendor_usecase.dart';

final vendorProfileProvider =
    AsyncNotifierProvider<VendorProfileNotifier, VendorEntity?>(
  VendorProfileNotifier.new,
);

class VendorProfileNotifier extends AsyncNotifier<VendorEntity?> {
  @override
  Future<VendorEntity?> build() async {
    try {
      return await GetVendorProfileUseCase(ref.watch(vendorRepositoryProvider))(
        const NoParams(),
      );
    } catch (e, st) {
      AppLogger.error(
        'No vendor profile yet',
        tag: 'VendorProfileNotifier',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<bool> register({
    required String businessName,
    required String address,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final vendor = await RegisterVendorUseCase(
        ref.read(vendorRepositoryProvider),
      )(RegisterVendorParams(
        businessName: businessName,
        address: address,
        phone: phone,
      ));
      AppLogger.info('Vendor registered: ${vendor.businessName}', tag: 'VendorProfileNotifier');
      state = AsyncValue.data(vendor);
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Vendor registration failed',
        tag: 'VendorProfileNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final vendorSalesProvider =
    AsyncNotifierProvider<VendorSalesNotifier, VendorSalesSummaryEntity>(
  VendorSalesNotifier.new,
);

class VendorSalesNotifier extends AsyncNotifier<VendorSalesSummaryEntity> {
  @override
  Future<VendorSalesSummaryEntity> build() async {
    return GetVendorSalesUseCase(ref.watch(vendorRepositoryProvider))(
      const NoParams(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final sales = await GetVendorSalesUseCase(
        ref.read(vendorRepositoryProvider),
      )(const NoParams());
      state = AsyncValue.data(sales);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final vendorOrdersProvider = FutureProvider.autoDispose((ref) async {
  return GetVendorOrdersUseCase(ref.watch(vendorRepositoryProvider))(
    const NoParams(),
  );
});
