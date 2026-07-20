import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../domain/entities/repair_category_entity.dart';
import '../providers/repair_categories_provider.dart';
import '../widgets/cancel_booking_sheet.dart';

class RepairBookingsListScreen extends ConsumerWidget {
  const RepairBookingsListScreen({super.key, this.embedded = false});

  /// When embedded inside the Activity hub the screen drops its own AppBar.
  final bool embedded;

  Color _statusColor(RepairStatus status) => switch (status) {
    RepairStatus.pending => AppColors.warningColor,
    RepairStatus.processing => AppColors.warningColor,
    RepairStatus.onTheWay => AppColors.primaryLight,
    RepairStatus.completed => AppColors.successColor,
    RepairStatus.cancelled => AppColors.errorColor,
  };

  IconData _iconFor(String serviceType) {
    final value = serviceType.toLowerCase();
    if (value.contains('electric')) return Icons.electrical_services_rounded;
    if (value.contains('cctv')) return Icons.videocam_rounded;
    if (value.contains('tech')) return Icons.computer_rounded;
    if (value.contains('plumb')) return Icons.plumbing_rounded;
    return Icons.build_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(repairBookingsListProvider);

    return Scaffold(
      appBar: embedded ? null : AppBar(title: const Text('My Bookings')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(repairBookingsListProvider),
        child: bookingsState.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.handyman_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('No bookings yet')),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          context.push(RouteNames.repairCategories),
                      child: const Text('Book a repair service'),
                    ),
                  ),
                ],
              );
            }
            final sorted = [...bookings]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final booking = sorted[index];
                final statusColor = _statusColor(booking.status);
                return GestureDetector(
                  onTap: () => context.push(
                    RouteNames.repairTracking.replaceFirst(':id', booking.id),
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
                                _iconFor(booking.categoryName),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.categoryName.isEmpty
                                        ? 'Repair Service'
                                        : booking.categoryName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Booking #${booking.id}',
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
                                booking.statusLabel,
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
                            const Icon(Icons.event_rounded, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${AppDateUtils.formatDate(booking.scheduledDate)} • ${booking.timeSlot}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        if (booking.charge != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.payments_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${AppConstants.currencySymbol} ${booking.charge!.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              booking.paymentMethod.toUpperCase() == 'QR'
                                  ? Icons.qr_code_2_rounded
                                  : Icons.account_balance_wallet_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Paying via ${booking.paymentMethod}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (booking.isCancellable) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _CardCancelButton(
                              bookingId: booking.id,
                              serviceName: booking.categoryName.isEmpty
                                  ? 'repair'
                                  : booking.categoryName,
                            ),
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
            onRetry: () => ref.invalidate(repairBookingsListProvider),
          ),
        ),
      ),
    );
  }
}

class _CardCancelButton extends ConsumerWidget {
  const _CardCancelButton({required this.bookingId, required this.serviceName});

  final String bookingId;
  final String serviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelling = ref.watch(repairCancelNotifierProvider);
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.errorColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: const Size(0, 36),
      ),
      onPressed: isCancelling
          ? null
          : () => confirmAndCancelBooking(
              context: context,
              ref: ref,
              bookingId: bookingId,
              serviceName: serviceName,
            ),
      icon: const Icon(Icons.cancel_outlined, size: 16),
      label: const Text('Cancel'),
    );
  }
}
