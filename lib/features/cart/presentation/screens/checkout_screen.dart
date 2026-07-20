import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../payment/presentation/widgets/payment_qr_card.dart';
import '../../../promo/data/promo_remote_datasource.dart';
import '../../../repair_service/presentation/widgets/location_address_field.dart';
import '../providers/cart_provider.dart';
import '../widgets/order_summary_card.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPayment = 'cod';
  bool _isPlacing = false;

  final _addressController = TextEditingController(
    text: 'Kathmandu-10, Baneshwor, Nepal',
  );
  double? _latitude;
  double? _longitude;

  // Promo state
  final _promoController = TextEditingController();
  bool _validatingPromo = false;
  PromoValidation? _appliedPromo;
  String? _promoError;

  // QR payment proof (local path until uploaded on submit)
  String? _paymentScreenshotPath;

  @override
  void dispose() {
    _addressController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double _deliveryFee(double subtotal) => subtotal > 1000 ? 0 : 100;

  double get _discount =>
      _appliedPromo?.valid == true ? _appliedPromo!.discountAmount : 0;

  Future<void> _applyPromo(double subtotal) async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _validatingPromo = true;
      _promoError = null;
    });
    final result = await ref
        .read(promoRemoteDataSourceProvider)
        .validate(code: code, cartSubTotal: subtotal);
    if (!mounted) return;
    setState(() {
      _validatingPromo = false;
      if (result.valid) {
        _appliedPromo = result;
        _promoError = null;
      } else {
        _appliedPromo = null;
        _promoError = result.message ?? 'Invalid promo code.';
      }
    });
  }

  void _clearPromo() {
    setState(() {
      _appliedPromo = null;
      _promoController.clear();
      _promoError = null;
    });
  }

  Future<void> _placeOrder() async {
    final cartState = ref.read(cartNotifierProvider);
    if (cartState.isEmpty) return;

    if (_addressController.text.trim().isEmpty) {
      _snack('Please enter a delivery address', isError: true);
      return;
    }
    if (_selectedPayment == 'qr' && _paymentScreenshotPath == null) {
      _snack(
        'Please upload your payment screenshot for QR payment',
        isError: true,
      );
      return;
    }

    setState(() => _isPlacing = true);
    final subtotal = cartState.total;
    final total = subtotal + _deliveryFee(subtotal) - _discount;

    final result = await ref
        .read(ordersNotifierProvider.notifier)
        .placeOrder(
          items: cartState.items,
          address: _addressController.text.trim(),
          paymentMethod: _selectedPayment,
          total: total,
          promoCode: _appliedPromo?.valid == true ? _appliedPromo!.code : null,
          paymentScreenshotLocalPath: _paymentScreenshotPath,
        );

    if (!mounted) return;
    setState(() => _isPlacing = false);

    if (!result.success) {
      _snack(result.message, isError: true);
      return;
    }

    ref.read(cartNotifierProvider.notifier).clearCart();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.successColor,
          size: 56,
        ),
        title: const Text('Order Placed!'),
        content: const Text(
          'Your order has been placed successfully. You can track it from Orders.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.orderList);
            },
            child: const Text('Track Order'),
          ),
        ],
      ),
    );
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.errorColor
            : AppColors.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final subtotal = cartState.total;
    final deliveryFee = _deliveryFee(subtotal);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Delivery Address'),
          const SizedBox(height: 8),
          // Same pattern as repair booking: real live location or manual entry.
          LocationAddressField(
            controller: _addressController,
            onLocationResolved: (lat, lng) {
              setState(() {
                _latitude = lat;
                _longitude = lng;
              });
            },
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Items (${cartState.itemCount})'),
          const SizedBox(height: 8),
          ...cartState.items.map(
            (item) => _CheckoutItemRow(
              name:
                  '${item.productName}'
                  '${item.variantLabel.isNotEmpty ? ' (${item.variantLabel})' : ''}',
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              onChanged: (q) => cartNotifier.updateQuantity(item.id, q),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Promo Code'),
          const SizedBox(height: 8),
          _PromoField(
            controller: _promoController,
            applied: _appliedPromo?.valid == true,
            isLoading: _validatingPromo,
            errorText: _promoError,
            appliedLabel: _appliedPromo?.valid == true
                ? '${_appliedPromo!.code} • ${_appliedPromo!.discountPercent.toStringAsFixed(0)}% off'
                : null,
            onApply: () => _applyPromo(subtotal),
            onClear: _clearPromo,
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Payment Method'),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: _selectedPayment,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedPayment = v;
                if (v != 'qr') _paymentScreenshotPath = null;
              });
            },
            child: Column(
              children: const [
                RadioListTile<String>(
                  value: 'cod',
                  title: Text(
                    'Cash on Delivery',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  secondary: Icon(Icons.money_rounded),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  value: 'qr',
                  title: Text(
                    'QR Pay',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  secondary: Icon(Icons.qr_code_rounded),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          if (_selectedPayment == 'qr') ...[
            const SizedBox(height: 8),
            PaymentQrCard(
              amount: subtotal + deliveryFee - _discount,
              screenshotPath: _paymentScreenshotPath,
              onScreenshotPicked: (path) =>
                  setState(() => _paymentScreenshotPath = path),
              onScreenshotCleared: () =>
                  setState(() => _paymentScreenshotPath = null),
            ),
          ],
          const SizedBox(height: 20),
          OrderSummaryCard(
            subtotal: subtotal,
            deliveryFee: deliveryFee,
            discount: _discount,
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: AppButton(
          label: 'Place Order',
          onPressed: _placeOrder,
          isLoading: _isPlacing,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _CheckoutItemRow extends StatelessWidget {
  const _CheckoutItemRow({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.onChanged,
  });

  final String name;
  final double unitPrice;
  final int quantity;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  FormatUtils.price(unitPrice * quantity),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: quantity > 1
                      ? () => onChanged(quantity - 1)
                      : null,
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: quantity < 99
                      ? () => onChanged(quantity + 1)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoField extends StatelessWidget {
  const _PromoField({
    required this.controller,
    required this.applied,
    required this.isLoading,
    required this.errorText,
    required this.appliedLabel,
    required this.onApply,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool applied;
  final bool isLoading;
  final String? errorText;
  final String? appliedLabel;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (applied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successColor.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.successColor.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              color: AppColors.successColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                appliedLabel ?? 'Promo applied',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.successColor,
                ),
              ),
            ),
            TextButton(onPressed: onClear, child: const Text('Remove')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Enter promo code',
                  prefixIcon: Icon(Icons.local_offer_outlined),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    88,
                    48,
                  ), // overrides the infinite-width theme default
                ),
                onPressed: isLoading ? null : onApply,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Apply'),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.errorColor),
          ),
        ],
      ],
    );
  }
}
