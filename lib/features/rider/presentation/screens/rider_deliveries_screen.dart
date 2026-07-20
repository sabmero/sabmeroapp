import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../domain/entities/rider_delivery_entity.dart';
import '../providers/rider_provider.dart';

class RiderDeliveriesScreen extends ConsumerWidget {
  const RiderDeliveriesScreen({super.key});

  Color _statusColor(RiderDeliveryStatus status) => switch (status) {
    RiderDeliveryStatus.dispatched => AppColors.statusShipped,
    RiderDeliveryStatus.delivered => AppColors.successColor,
    RiderDeliveryStatus.cancelled => AppColors.errorColor,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(riderDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Deliveries')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(riderDeliveriesProvider.notifier).refresh(),
        child: state.when(
          data: (deliveries) {
            if (deliveries.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.two_wheeler_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('No deliveries assigned yet')),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      "You'll be notified as soon as admin assigns you a delivery.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            final sorted = [...deliveries]..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              return b.createdAt.compareTo(a.createdAt);
            });
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final d = sorted[index];
                final statusColor = _statusColor(d.status);
                return GestureDetector(
                  onTap: () => context.push(
                    RouteNames.riderJobDetail.replaceFirst(':id', d.id),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.two_wheeler_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.customerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Order #${d.id} • ${d.items.length} item(s)',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondaryLight,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(28),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                d.statusLabel,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                d.deliveryAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              d.customerPhone,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (d.isCashOnDelivery) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Collect ${AppConstants.currencySymbol} ${d.totalAmount.toStringAsFixed(0)} (COD)',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const CardListSkeleton(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.read(riderDeliveriesProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
