import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/service_catalog_provider.dart';
import '../widgets/service_offer_card.dart';

/// One service category: its sub-categories as filter chips and the services
/// and packages listed under it. Products never appear here.
class ServiceCategoryScreen extends ConsumerStatefulWidget {
  const ServiceCategoryScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  ConsumerState<ServiceCategoryScreen> createState() =>
      _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends ConsumerState<ServiceCategoryScreen> {
  int? _subId;

  @override
  Widget build(BuildContext context) {
    final treeAsync = ref.watch(serviceCategoryTreeProvider);
    final offersAsync = ref.watch(serviceOffersProvider);
    final node = treeAsync.asData == null
        ? null
        : findServiceCategory(treeAsync.asData!.value, widget.categoryId);

    return Scaffold(
      appBar: AppBar(title: Text(node?.name ?? 'Services')),
      body: treeAsync.when(
        loading: () => const CardListSkeleton(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(serviceCategoryTreeProvider),
        ),
        data: (roots) {
          if (node == null) {
            return const Center(child: Text('This category is not available.'));
          }

          final ids = _subId != null ? {_subId!} : node.allIds.toSet();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(serviceCategoryTreeProvider);
              ref.invalidate(serviceOffersProvider);
              await ref.read(serviceOffersProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (node.children.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _subId == null,
                        onSelected: (_) => setState(() => _subId = null),
                      ),
                      for (final sub in node.children)
                        ChoiceChip(
                          label: Text(sub.name),
                          selected: _subId == sub.id,
                          onSelected: (_) => setState(() => _subId = sub.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                offersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => AppErrorWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(serviceOffersProvider),
                  ),
                  data: (all) {
                    final offers = all
                        .where(
                          (o) =>
                              o.categoryId != null && ids.contains(o.categoryId),
                        )
                        .toList();
                    if (offers.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No services are listed here yet.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final o in offers) ...[
                          ServiceOfferCard(offer: o),
                          const SizedBox(height: 12),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Always possible to book a technician for this category, even
                // when no individual service is listed yet.
                OutlinedButton.icon(
                  icon: const Icon(Icons.build_rounded),
                  label: Text('Book a technician for ${node.name}'),
                  onPressed: () => context.push(
                    RouteNames.repairBooking,
                    extra: {
                      'categoryId': 'cat_${node.id}',
                      'categoryName': node.name,
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
