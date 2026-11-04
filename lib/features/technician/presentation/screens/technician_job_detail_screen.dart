import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/activity_timeline.dart';
import '../../../../core/widgets/collection_dialog.dart';
import '../../data/datasources/technician_remote_datasource.dart';
import '../../domain/entities/technician_job_entity.dart';
import '../providers/technician_provider.dart';

class TechnicianJobDetailScreen extends ConsumerStatefulWidget {
  const TechnicianJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<TechnicianJobDetailScreen> createState() =>
      _TechnicianJobDetailScreenState();
}

class _TechnicianJobDetailScreenState
    extends ConsumerState<TechnicianJobDetailScreen> {
  bool _updating = false;
  bool _refetched = false; // reload the list once if the job isn't in it yet

  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _showSnack('Could not open ${uri.scheme}');
    } catch (e, st) {
      AppLogger.error('Failed to launch ${uri.scheme}',
          tag: 'TechnicianJobDetail', error: e, stackTrace: st);
      if (mounted) _showSnack('Something went wrong');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _callCustomer(String phone) =>
      _launch(Uri(scheme: 'tel', path: phone));

  Future<void> _navigateToAddress(TechnicianJobEntity job) {
    // Prefer a lat/long pin when the customer set one on the map, otherwise
    // fall back to a text search on the typed address.
    final uri = (job.latitude != 0 || job.longitude != 0)
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${job.latitude},${job.longitude}',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(job.serviceAddress)}',
          );
    return _launch(uri);
  }

  Future<void> _advance(TechnicianJobEntity job) async {
    final next = job.nextStatus;
    if (next == null) return;

    _Collection? collection;
    if (next == TechnicianJobStatus.completed) {
      collection = await _promptForCollection(job.serviceCharge);
      if (collection == null) return; // cancelled
    }

    setState(() => _updating = true);

    // Online payment: upload the screenshot first, then complete the job.
    String? proofPath;
    if (collection != null &&
        collection.method == 'Online' &&
        collection.screenshotLocalPath != null) {
      try {
        proofPath = await ref
            .read(technicianRemoteDataSourceProvider)
            .uploadPaymentProof(collection.screenshotLocalPath!);
      } catch (e, st) {
        AppLogger.error('Proof upload failed',
            tag: 'TechnicianJobDetail', error: e, stackTrace: st);
      }
      if (proofPath == null || proofPath.isEmpty) {
        if (!mounted) return;
        setState(() => _updating = false);
        _showSnack('Could not upload the screenshot. Try again.');
        return;
      }
    }

    final ok = await ref.read(technicianJobsProvider.notifier).updateStatus(
          job.id,
          next,
          serviceCharge: collection?.amount,
          collectionMethod: collection?.method,
          amountInWords: collection?.amountInWords,
          collectionScreenshotPath: proofPath,
        );
    if (!mounted) return;
    setState(() => _updating = false);
    ref.invalidate(activityTimelineProvider((kind: 'booking', id: job.id)));
    _showSnack(ok ? 'Job updated' : 'Failed to update job. Try again.');
  }

  /// Asks how much was collected and how: Cash (amount written in words) or
  /// Online (payment screenshot).
  Future<_Collection?> _promptForCollection(double? existing) async {
    final r = await showCollectionDialog(
      context,
      initialAmount: existing,
      confirmLabel: 'Mark Completed',
    );
    if (r == null) return null;
    return _Collection(
      amount: r.amount,
      method: r.method,
      amountInWords: r.amountInWords,
      screenshotLocalPath: r.screenshotLocalPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(technicianJobByIdProvider(widget.jobId));

    if (job == null) {
      // Opened from a notification: the list may not be loaded yet, or may
      // have been loaded before this job was assigned. Load it (once) before
      // giving up.
      final jobsAsync = ref.watch(technicianJobsProvider);
      if (jobsAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Job Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (!_refetched) {
        _refetched = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(technicianJobsProvider.notifier).refresh();
        });
        return Scaffold(
          appBar: AppBar(title: const Text('Job Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Job not found'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(technicianJobsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Job #${job.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Customer',
            children: [
              _InfoRow(icon: Icons.person_outline, label: job.customerName),
              _InfoRow(icon: Icons.phone_outlined, label: job.customerPhone),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: job.serviceAddress,
              ),
            ],
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed: job.customerPhone.isEmpty
                      ? null
                      : () => _callCustomer(job.customerPhone),
                  icon: const Icon(Icons.call_rounded),
                  tooltip: 'Call customer',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _navigateToAddress(job),
                  icon: const Icon(Icons.directions_rounded),
                  tooltip: 'Navigate',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Job',
            children: [
              _InfoRow(icon: Icons.build_outlined, label: job.serviceType),
              _InfoRow(
                icon: Icons.event_outlined,
                label:
                    '${AppDateUtils.formatDate(job.bookingDate)} • ${job.timeSlot}',
              ),
              _InfoRow(
                icon: job.paymentMethod.toUpperCase() == 'QR'
                    ? Icons.qr_code_2_rounded
                    : Icons.account_balance_wallet_outlined,
                label: 'Paying via ${job.paymentMethod} (${job.paymentStatus})',
              ),
              if (job.serviceCharge != null)
                _InfoRow(
                  icon: Icons.payments_outlined,
                  label:
                      'Collect from customer: ${AppConstants.currencySymbol} ${job.serviceCharge!.toStringAsFixed(0)}',
                ),
            ],
          ),
          if ((job.description ?? '').trim().isNotEmpty ||
              job.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Problem details',
              children: [
                if ((job.description ?? '').trim().isNotEmpty)
                  _InfoRow(
                    icon: Icons.notes_rounded,
                    label: job.description!.trim(),
                  ),
                if (job.images.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: job.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) => GestureDetector(
                        onTap: () => showDialog(
                          context: ctx,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: CachedNetworkImage(
                                imageUrl: job.images[i],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: job.images[i],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const SizedBox(
                              width: 120,
                              height: 120,
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          ActivityTimelineCard(
            kind: 'booking',
            id: job.id,
            title: 'Job history',
            showStaff: false,
          ),
          const SizedBox(height: 24),
          if (job.nextStatus != null)
            FilledButton.icon(
              onPressed: _updating ? null : () => _advance(job),
              icon: _updating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(job.nextStatusActionLabel),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            )
          else
            Center(
              child: Text(
                'Job completed',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Collection {
  const _Collection({
    required this.amount,
    required this.method,
    this.amountInWords,
    this.screenshotLocalPath,
  });

  final double amount;
  final String method; // 'Cash' | 'Online'
  final String? amountInWords;
  final String? screenshotLocalPath;
}
