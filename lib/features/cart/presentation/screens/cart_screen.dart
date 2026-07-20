import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/core/constants/asset_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/order_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cartState.itemCount})'),
        actions: [
          if (!cartState.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cartNotifier),
              child: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? _EmptyCart()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...cartState.items.map(
                  (item) => CartItemTile(
                    item: item,
                    onRemove: () => cartNotifier.removeItem(item.id),
                    onQuantityChanged: (q) =>
                        cartNotifier.updateQuantity(item.id, q),
                  ),
                ),
                const SizedBox(height: 16),
                OrderSummaryCard(
                  subtotal: cartState.total,
                  deliveryFee: cartState.total > 1000 ? 0 : 100,
                  discount: 0,
                ),
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: cartState.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: AppButton(
                label: 'Proceed to Checkout',
                onPressed: () => context.push(RouteNames.checkout),
              ),
            ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    CartNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) notifier.clearCart();
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AssetConstants.emptyCart,
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }
}
