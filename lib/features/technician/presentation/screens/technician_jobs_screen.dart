import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../domain/entities/technician_job_entity.dart';
import '../providers/technician_provider.dart';

class TechnicianJobsScreen extends ConsumerWidget {
  const TechnicianJobsScreen({super.key});

  Color _statusColor(TechnicianJobStatus status) => switch (status) {
    TechnicianJobStatus.approved => AppColors.warningColor,
    TechnicianJobStatus.processing => AppColors.primaryLight,
    TechnicianJobStatus.onTheWay => AppColors.statusShipped,
    TechnicianJobStatus.completed => AppColors.successColor,
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
    final jobsState = ref.watch(technicianJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(technicianJobsProvider.notifier).refresh(),
        child: jobsState.when(
          data: (jobs) {
            if (jobs.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.handyman_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('No jobs assigned yet')),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      "You'll be notified as soon as admin assigns you a job.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            // Active jobs first, completed ones at the bottom.
            final sorted = [...jobs]..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              return b.createdAt.compareTo(a.createdAt);
            });
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final job = sorted[index];
                final statusColor = _statusColor(job.status);
                return GestureDetector(
                  onTap: () => context.push(
                    RouteNames.technicianJobDetail.replaceFirst(':id', job.id),
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
                                _iconFor(job.serviceType),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.customerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${job.serviceType} • #${job.id}',
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
                                job.statusLabel,
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
                              '${AppDateUtils.formatDate(job.bookingDate)} • ${job.timeSlot}',
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
                                job.serviceAddress,
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
                              job.customerPhone,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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
            onRetry: () => ref.read(technicianJobsProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }
}
