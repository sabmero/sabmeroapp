import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/rider_delivery_entity.dart';
import '../providers/rider_provider.dart';

class RiderDeliveryDetailScreen extends ConsumerStatefulWidget {
  const RiderDeliveryDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<RiderDeliveryDetailScreen> createState() =>
      _RiderDeliveryDetailScreenState();
}

class _RiderDeliveryDetailScreenState
    extends ConsumerState<RiderDeliveryDetailScreen> {
  bool _updating = false;

  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _showSnack('Could not open ${uri.scheme}');
    } catch (e, st) {
      AppLogger.error('Failed to launch ${uri.scheme}',
          tag: 'RiderDeliveryDetail', error: e, stackTrace: st);
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

  Future<void> _navigateToAddress(String address) => _launch(
        Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
        ),
      );

  Future<void> _markDelivered(RiderDeliveryEntity d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as delivered?'),
        content: Text(
          d.isCashOnDelivery
              ? 'Confirm you have collected ${AppConstants.currencySymbol} ${d.totalAmount.toStringAsFixed(0)} from the customer.'
              : 'This will mark order #${d.id} as delivered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updating = true);
    final ok = await ref.read(riderDeliveriesProvider.notifier).markDelivered(d.id);
    if (!mounted) return;
    setState(() => _updating = false);
    _showSnack(ok ? 'Delivery updated' : 'Failed to update. Try again.');
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(riderDeliveryByIdProvider(widget.orderId));

    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Details')),
        body: const Center(child: Text('Delivery not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${d.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Customer',
            children: [
              _InfoRow(icon: Icons.person_outline, label: d.customerName),
              _InfoRow(icon: Icons.phone_outlined, label: d.customerPhone),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: d.deliveryAddress,
              ),
            ],
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed: d.customerPhone.isEmpty
                      ? null
                      : () => _callCustomer(d.customerPhone),
                  icon: const Icon(Icons.call_rounded),
                  tooltip: 'Call customer',
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _navigateToAddress(d.deliveryAddress),
                  icon: const Icon(Icons.directions_rounded),
                  tooltip: 'Navigate',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Order',
            children: [
              for (final item in d.items)
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: '${item.quantity}x ${item.productName}',
                ),
              _InfoRow(
                icon: d.paymentMethod.toUpperCase() == 'QR'
                    ? Icons.qr_code_2_rounded
                    : Icons.account_balance_wallet_outlined,
                label: 'Paying via ${d.paymentMethod} (${d.paymentStatus})',
              ),
              _InfoRow(
                icon: Icons.payments_outlined,
                label:
                    'Total: ${AppConstants.currencySymbol} ${d.totalAmount.toStringAsFixed(0)}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (d.isActive)
            FilledButton.icon(
              onPressed: _updating ? null : () => _markDelivered(d),
              icon: _updating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Mark Delivered'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            )
          else
            Center(
              child: Text(
                d.statusLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: d.status == RiderDeliveryStatus.delivered
                          ? AppColors.successColor
                          : AppColors.errorColor,
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
