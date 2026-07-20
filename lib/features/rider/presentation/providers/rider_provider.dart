import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/rider_remote_datasource.dart';
import '../../domain/entities/rider_delivery_entity.dart';

/// The logged-in rider's assigned deliveries, newest first.
final riderDeliveriesProvider =
    AsyncNotifierProvider<RiderDeliveriesNotifier, List<RiderDeliveryEntity>>(
      RiderDeliveriesNotifier.new,
    );

class RiderDeliveriesNotifier extends AsyncNotifier<List<RiderDeliveryEntity>> {
  @override
  Future<List<RiderDeliveryEntity>> build() async {
    final deliveries = await ref
        .watch(riderRemoteDataSourceProvider)
        .getMyDeliveries();
    final sorted = [...deliveries]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final deliveries = await ref
          .read(riderRemoteDataSourceProvider)
          .getMyDeliveries();
      return [...deliveries]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<bool> markDelivered(String orderId) async {
    try {
      await ref
          .read(riderRemoteDataSourceProvider)
          .updateDeliveryStatus(orderId, RiderDeliveryStatus.delivered);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update delivery $orderId',
        tag: 'RiderDeliveriesNotifier',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

final riderDeliveryByIdProvider = Provider.family<RiderDeliveryEntity?, String>(
  (ref, id) {
    final deliveries =
        ref.watch(riderDeliveriesProvider).asData?.value ?? const [];
    for (final d in deliveries) {
      if (d.id == id) return d;
    }
    return null;
  },
);
