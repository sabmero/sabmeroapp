import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/activity_timeline.dart';
import '../../../../core/widgets/collection_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/datasources/rider_remote_datasource.dart';
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
  bool _refetched = false; // reload the list once if the order isn't in it yet

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
    _Collection? collection;
    if (d.isCashOnDelivery) {
      // Cash on delivery: how was the money collected?
      collection = await _promptForCollection(d);
      if (collection == null) return; // cancelled
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mark as delivered?'),
          content: Text('This will mark order #${d.id} as delivered.'),
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
    }

    setState(() => _updating = true);

    // Online payment: upload the screenshot first.
    String? proofPath;
    if (collection != null &&
        collection.method == 'Online' &&
        collection.screenshotLocalPath != null) {
      try {
        proofPath = await ref
            .read(riderRemoteDataSourceProvider)
            .uploadPaymentProof(collection.screenshotLocalPath!);
      } catch (e, st) {
        AppLogger.error('Proof upload failed',
            tag: 'RiderDeliveryDetail', error: e, stackTrace: st);
      }
      if (proofPath == null || proofPath.isEmpty) {
        if (!mounted) return;
        setState(() => _updating = false);
        _showSnack('Could not upload the screenshot. Try again.');
        return;
      }
    }

    final ok = await ref.read(riderDeliveriesProvider.notifier).markDelivered(
          d.id,
          collectionMethod: collection?.method,
          amountInWords: collection?.amountInWords,
          collectionScreenshotPath: proofPath,
        );
    if (!mounted) return;
    setState(() => _updating = false);
    ref.invalidate(activityTimelineProvider((kind: 'order', id: d.id)));
    _showSnack(ok ? 'Delivery updated' : 'Failed to update. Try again.');
  }

  /// Cash-on-delivery hand-over: Cash (amount written in words) or Online
  /// (screenshot of the customer's payment).
  Future<_Collection?> _promptForCollection(RiderDeliveryEntity d) async {
    final r = await showCollectionDialog(
      context,
      fixedAmount: d.totalAmount,
      confirmLabel: 'Mark Delivered',
    );
    if (r == null) return null;
    return _Collection(
      method: r.method,
      amountInWords: r.amountInWords,
      screenshotLocalPath: r.screenshotLocalPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(riderDeliveryByIdProvider(widget.orderId));

    if (d == null) {
      // Opened from a notification: load the list (once) before giving up.
      final listAsync = ref.watch(riderDeliveriesProvider);
      if (listAsync.isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text('Delivery Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      if (!_refetched) {
        _refetched = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(riderDeliveriesProvider.notifier).refresh();
        });
        return Scaffold(
          appBar: AppBar(title: const Text('Delivery Details')),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Details')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Delivery not found'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(riderDeliveriesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: item.imageUrl.isEmpty
                            ? const SizedBox(
                                width: 64,
                                height: 64,
                                child: Icon(Icons.inventory_2_outlined),
                              )
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
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
          const SizedBox(height: 16),
          ActivityTimelineCard(
            kind: 'order',
            id: d.id,
            title: 'Delivery history',
            showStaff: false,
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

class _Collection {
  const _Collection({
    required this.method,
    this.amountInWords,
    this.screenshotLocalPath,
  });

  final String method; // 'Cash' | 'Online'
  final String? amountInWords;
  final String? screenshotLocalPath;
}
