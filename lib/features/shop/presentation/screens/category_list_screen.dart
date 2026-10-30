import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_image.dart';

void _openCategory(BuildContext context, CategoryEntity category) {
  context.push(
    RouteNames.productList,
    extra: {'categoryId': category.id, 'categoryName': category.name},
  );
}

/// Product categories, shown two ways:
///  * Main Category  - image grid of categories that currently have products.
///  * All Categories - every product category from the backend, searchable.
/// Service categories are intentionally NOT part of this screen.
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w700),
            tabs: [
              Tab(text: 'Main Category'),
              Tab(text: 'All Categories'),
            ],
          ),
        ),
        body: categoriesState.when(
          data: (categories) => TabBarView(
            children: [
              _MainCategoryTab(categories: categories),
              _AllCategoriesTab(categories: categories),
            ],
          ),
          loading: () => const AppLoader(),
          error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(categoriesNotifierProvider),
          ),
        ),
      ),
    );
  }
}

class _MainCategoryTab extends StatelessWidget {
  const _MainCategoryTab({required this.categories});

  final List<CategoryEntity> categories;

  @override
  Widget build(BuildContext context) {
    final main = categories.where((c) => c.productCount > 0).toList();

    if (main.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No categories with products yet.\nSee the All Categories tab.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Tile height follows the user's font size so large-text phones don't overflow.
    final scaler = MediaQuery.textScalerOf(context);
    final tileHeight =
        16 + 56 + 8 + scaler.scale(12) * 1.5 * 2 + 2 + scaler.scale(11) * 1.5 + 8;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: tileHeight,
      ),
      itemCount: main.length,
      itemBuilder: (context, index) {
        final category = main[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openCategory(context, category),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryImage(imageUrl: category.imageUrl, size: 56),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${category.productCount} items',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AllCategoriesTab extends StatefulWidget {
  const _AllCategoriesTab({required this.categories});

  final List<CategoryEntity> categories;

  @override
  State<_AllCategoriesTab> createState() => _AllCategoriesTabState();
}

class _AllCategoriesTabState extends State<_AllCategoriesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final visible = q.isEmpty
        ? widget.categories
        : widget.categories
              .where((c) => c.name.toLowerCase().contains(q))
              .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Filter categories',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No matching categories'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = visible[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openCategory(context, category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            CategoryImage(
                              imageUrl: category.imageUrl,
                              size: 44,
                              radius: 10,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${category.productCount} items',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
