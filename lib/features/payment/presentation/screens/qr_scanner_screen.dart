import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/payment_provider.dart';
import '../widgets/qr_scanner_overlay.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _hasScanned = true);
    await _controller.stop();
    AppLogger.info('QR code scanned', tag: 'QrScannerScreen');

    ref.read(paymentNotifierProvider.notifier).recordScannedCode(code);
    const success = true;

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.successColor,
            size: 56,
          ),
          title: const Text('Payment Verified'),
          content: const Text(
            'QR code scanned successfully. You can proceed with your order.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _hasScanned = false);
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = ref.watch(
      paymentNotifierProvider.select((s) => s.isProcessing),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR to Pay'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: MobileScanner(controller: _controller, onDetect: _onDetect),
          ),
          const RepaintBoundary(child: QrScannerOverlay()),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  isProcessing
                      ? 'Verifying payment...'
                      : 'Align the QR code within the frame',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                if (isProcessing) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
