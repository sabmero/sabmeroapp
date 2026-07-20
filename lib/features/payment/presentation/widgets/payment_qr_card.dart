import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sabmeroapp/features/payment/data/repositories/payment_repository_impl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/payment_provider.dart';

/// Fetches the payment QR the admin uploaded (GET /api/Payments/qr).
/// Returns null when no QR has been configured yet.
final adminQrProvider = FutureProvider.autoDispose<String?>((ref) async {
  // Fetch directly from the repository. Do NOT go through
  // paymentNotifierProvider here — its loadQr() mutates notifier state,
  // which Riverpod forbids while another provider is initializing
  // (it throws, which showed up as a fake "connection error").
  final info = await ref.read(paymentRepositoryProvider).getQr();
  final path = info.qrImagePath;
  if (path == null || path.isEmpty) return null;
  return path.startsWith('http') ? path : '${ApiConstants.serverOrigin}$path';
});

/// Shows a (dummy) payment QR and lets the customer attach a payment-proof
/// screenshot. Used by both product checkout and repair-service booking when
/// the customer chooses QR.
///
/// [screenshotPath] is the locally picked file path (null until chosen). The
/// caller uploads it (POST /Uploads/payment) and sends the returned server
/// path with the order/booking.
class PaymentQrCard extends ConsumerWidget {
  const PaymentQrCard({
    super.key,
    required this.amount,
    required this.screenshotPath,
    required this.onScreenshotPicked,
    required this.onScreenshotCleared,
    this.merchantName = 'SabMero',
  });

  final double amount;
  final String? screenshotPath;
  final void Function(String path) onScreenshotPicked;
  final VoidCallback onScreenshotCleared;
  final String merchantName;

  Future<void> _pickScreenshot() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) onScreenshotPicked(picked.path);
    } catch (e, st) {
      AppLogger.error(
        'Payment screenshot pick failed',
        tag: 'PaymentQrCard',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(adminQrProvider);
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(
            'Scan to Pay',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Pay ${AppConstants.currencySymbol} ${amount.toStringAsFixed(2)} to $merchantName',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          // The real payment QR uploaded by the admin. Falls back to the
          // bundled sample only while loading fails or nothing is set yet.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: qrAsync.when(
              loading: () => const SizedBox(
                width: 180,
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const _QrUnavailable(
                message:
                    'Could not load the payment QR.\nCheck your connection and try again.',
              ),
              data: (url) => url == null
                  ? const _QrUnavailable(
                      message:
                          'Payment QR is not available yet.\nPlease use Cash on Delivery or try later.',
                    )
                  : CachedNetworkImage(
                      imageUrl: url,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 180,
                        height: 180,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => const _QrUnavailable(
                        message: 'Could not load the payment QR image.',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          qrAsync.maybeWhen(
            data: (url) => url == null
                ? Text(
                    'QR payment is temporarily unavailable',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Upload Payment Screenshot',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'After paying, attach a screenshot as proof of payment.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (screenshotPath == null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickScreenshot,
                icon: const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Choose Screenshot'),
              ),
            )
          else
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(screenshotPath!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.successColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Screenshot attached',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onScreenshotCleared,
                  child: const Text('Change'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Shown when no payment QR is configured or it failed to load. Keeps the
/// card size stable so the layout doesn't jump.
class _QrUnavailable extends StatelessWidget {
  const _QrUnavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
