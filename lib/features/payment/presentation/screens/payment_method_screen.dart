import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_tile.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(
      paymentNotifierProvider.select((s) => s.selectedMethod),
    );
    final notifier = ref.read(paymentNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Method')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose how you want to pay',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your payment is processed securely',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          PaymentMethodTile(
            icon: Icons.money_rounded,
            title: 'Cash on Delivery',
            subtitle: 'Pay with cash when your order arrives',
            isSelected: selectedMethod == PaymentMethodType.cashOnDelivery,
            onTap: () =>
                notifier.selectMethod(PaymentMethodType.cashOnDelivery),
          ),
          PaymentMethodTile(
            icon: Icons.qr_code_rounded,
            title: 'QR Pay',
            subtitle: 'Scan a QR code to pay instantly',
            isSelected: selectedMethod == PaymentMethodType.qrPay,
            onTap: () => notifier.selectMethod(PaymentMethodType.qrPay),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: AppButton(
          label: selectedMethod == PaymentMethodType.qrPay
              ? 'Scan QR Code'
              : 'Confirm Payment Method',
          onPressed: () {
            if (selectedMethod == PaymentMethodType.qrPay) {
              context.push(RouteNames.qrScanner);
            } else {
              context.pop();
            }
          },
        ),
      ),
    );
  }
}
