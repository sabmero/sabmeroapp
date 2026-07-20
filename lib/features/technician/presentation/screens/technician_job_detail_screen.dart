import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/app_logger.dart';
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

    double? charge;
    if (next == TechnicianJobStatus.completed) {
      charge = await _promptForCharge(job.serviceCharge);
      if (charge == null) return; // cancelled
    }

    setState(() => _updating = true);
    final ok = await ref
        .read(technicianJobsProvider.notifier)
        .updateStatus(job.id, next, serviceCharge: charge);
    if (!mounted) return;
    setState(() => _updating = false);
    _showSnack(ok ? 'Job updated' : 'Failed to update job. Try again.');
  }

  Future<double?> _promptForCharge(double? existing) async {
    final controller = TextEditingController(
      text: existing != null ? existing.toStringAsFixed(0) : '',
    );
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final service charge'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '${AppConstants.currencySymbol} ',
            hintText: 'Enter the amount collected',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.pop(context, value ?? 0);
            },
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(technicianJobByIdProvider(widget.jobId));

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('Job not found')),
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
                      '${AppConstants.currencySymbol} ${job.serviceCharge!.toStringAsFixed(0)}',
                ),
            ],
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
