import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../domain/entities/vendor_entity.dart';
import '../providers/vendor_products_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/commission_breakdown_card.dart';
import '../widgets/sales_summary_card.dart';
import '../widgets/vendor_product_tile.dart';

class VendorDashboardScreen extends ConsumerWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(vendorProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'My Orders',
            onPressed: () => context.push(RouteNames.vendorOrders),
          ),
        ],
      ),
      body: profileState.when(
        data: (vendor) {
          if (vendor == null) {
            return _NotRegistered();
          }
          if (!vendor.isApproved) {
            return _PendingApproval(vendor: vendor);
          }
          return _DashboardContent();
        },
        loading: () => const CardListSkeleton(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(vendorProfileProvider),
        ),
      ),
      floatingActionButton: profileState.asData?.value?.isApproved == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteNames.vendorProductForm),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            )
          : null,
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesState = ref.watch(vendorSalesProvider);
    final productsState = ref.watch(vendorProductsNotifierProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(vendorSalesProvider.notifier).refresh();
        await ref.read(vendorProductsNotifierProvider.notifier).refresh();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          salesState.when(
            data: (summary) => Column(
              children: [
                SalesSummaryCard(summary: summary),
                const SizedBox(height: 16),
                CommissionBreakdownCard(summary: summary),
              ],
            ),
            loading: () => const Shimmer(
              child: Column(
                children: [
                  SkeletonBox(
                    width: double.infinity,
                    height: 120,
                    borderRadius: 12,
                  ),
                  SizedBox(height: 16),
                  SkeletonBox(
                    width: double.infinity,
                    height: 100,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
            error: (e, _) => AppErrorWidget(message: e.toString()),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'My Products',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push(RouteNames.vendorProductForm),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          productsState.when(
            data: (products) => products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No products yet. Tap Add to create your first product.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Column(
                    children: products
                        .map(
                          (p) => VendorProductTile(
                            product: p,
                            onEdit: () => context.push(
                              RouteNames.vendorProductForm,
                              extra: p.id,
                            ),
                            onDelete: () =>
                                _confirmDelete(context, ref, p.id, p.name),
                          ),
                        )
                        .toList(),
                  ),
            loading: () =>
                const CardListSkeleton(itemCount: 4, padding: EdgeInsets.zero),
            error: (e, _) => AppErrorWidget(message: e.toString()),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String productId,
    String productName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Remove "$productName" from your store?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(vendorProductsNotifierProvider.notifier)
          .deleteProduct(productId);
    }
  }
}

class _NotRegistered extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'You are not a registered vendor yet',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your business to start selling on sabmero',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/vendor/register'),
              child: const Text('Register as Vendor'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingApproval extends StatelessWidget {
  const _PendingApproval({required this.vendor});
  final VendorEntity vendor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              size: 72,
              color: AppColors.warningColor,
            ),
            const SizedBox(height: 16),
            Text(
              vendor.businessName,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Pending Approval',
                style: TextStyle(
                  color: AppColors.warningColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your application is under review by our team. This usually takes 1-2 business days.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
