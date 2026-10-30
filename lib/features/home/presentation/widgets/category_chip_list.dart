import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../shop/presentation/providers/categories_provider.dart';
import '../../../shop/presentation/widgets/category_image.dart';

/// Horizontal "Shop by Main Category" row (product categories only).
/// Shows categories that have products; falls back to all categories if none do.
class CategoryChipList extends ConsumerWidget {
  const CategoryChipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesNotifierProvider);

    return categoriesState.when(
      data: (all) {
        final withProducts = all.where((c) => c.productCount > 0).toList();
        final categories = withProducts.isNotEmpty ? withProducts : all;
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.push(
                  RouteNames.productList,
                  extra: {'categoryId': cat.id, 'categoryName': cat.name},
                ),
                child: SizedBox(
                  width: 78,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        CategoryImage(imageUrl: cat.imageUrl, size: 60),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const ChipRowSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
