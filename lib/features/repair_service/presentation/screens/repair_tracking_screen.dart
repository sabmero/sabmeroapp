import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../reviews/presentation/widgets/review_list.dart';
import '../../domain/entities/repair_category_entity.dart';
import '../providers/repair_categories_provider.dart';
import '../widgets/status_step_indicator.dart';
import '../widgets/cancel_booking_sheet.dart';
import '../../../../core/constants/app_constants.dart';

class RepairTrackingScreen extends ConsumerWidget {
  const RepairTrackingScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(repairBookingsListProvider);

    return bookingsState.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Repair Tracking')),
            body: const AppErrorWidget(message: 'Booking not found'),
          );
        }
        // Explicitly typed nullable lookup avoids the firstWhere `orElse`
        // reified-subtype mismatch (List runtime type is RepairBookingModel
        // while the closure returns RepairBookingEntity).
        RepairBookingEntity? match;
        for (final b in bookings) {
          if (b.id == bookingId) {
            match = b;
            break;
          }
        }
        final booking = match ?? bookings.first;
        return Scaffold(
          appBar: AppBar(title: const Text('Repair Tracking')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withAlpha(200),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.build_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          booking.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BookingDetail(
                      icon: Icons.calendar_today_outlined,
                      label: AppDateUtils.formatDate(booking.scheduledDate),
                      dark: true,
                    ),
                    const SizedBox(height: 6),
                    _BookingDetail(
                      icon: Icons.access_time_outlined,
                      label: booking.timeSlot,
                      dark: true,
                    ),
                    const SizedBox(height: 6),
                    _BookingDetail(
                      icon: Icons.location_on_outlined,
                      label: booking.address,
                      dark: true,
                    ),
                    if (booking.technicianName != null) ...[
                      const SizedBox(height: 6),
                      _BookingDetail(
                        icon: Icons.person_outlined,
                        label: 'Technician: ${booking.technicianName}',
                        dark: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Service Status',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              StatusStepIndicator(currentStatus: booking.status),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      booking.paymentMethod.toUpperCase() == 'QR'
                          ? Icons.qr_code_2_rounded
                          : Icons.payments_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Payment: ${booking.paymentMethod}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (booking.charge != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successColor,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service Completed',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.successColor,
                            ),
                          ),
                          Text(
                            'Charge: ${AppConstants.currencySymbol} ${booking.charge!.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (booking.isCancellable) ...[
                const SizedBox(height: 24),
                _CancelButton(
                  bookingId: booking.id,
                  serviceName: booking.categoryName.isEmpty
                      ? 'repair'
                      : booking.categoryName,
                ),
              ],
              if (booking.status == RepairStatus.completed) ...[
                const SizedBox(height: 24),
                ReviewList(
                  targetId: booking.id,
                  targetName: booking.categoryName.isEmpty
                      ? 'this service'
                      : booking.categoryName,
                  targetType: 'service',
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: DetailSkeleton()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(message: e.toString()),
      ),
    );
  }
}

class _CancelButton extends ConsumerWidget {
  const _CancelButton({required this.bookingId, required this.serviceName});

  final String bookingId;
  final String serviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelling = ref.watch(repairCancelNotifierProvider);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.errorColor,
          side: const BorderSide(color: AppColors.errorColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isCancelling
            ? null
            : () async {
                final cancelled = await confirmAndCancelBooking(
                  context: context,
                  ref: ref,
                  bookingId: bookingId,
                  serviceName: serviceName,
                );
                if (cancelled && context.mounted) {
                  Navigator.of(context).maybePop();
                }
              },
        icon: isCancelling
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.errorColor,
                ),
              )
            : const Icon(Icons.cancel_outlined, size: 18),
        label: Text(isCancelling ? 'Cancelling...' : 'Cancel Booking'),
      ),
    );
  }
}

class _BookingDetail extends StatelessWidget {
  const _BookingDetail({
    required this.icon,
    required this.label,
    this.dark = false,
  });
  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: dark ? Colors.white.withAlpha(200) : null),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: dark ? Colors.white.withAlpha(220) : null,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
