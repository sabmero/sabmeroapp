import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/core/constants/asset_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../service_catalog/data/models/service_catalog_models.dart';
import '../../../service_catalog/presentation/providers/service_catalog_provider.dart';
import '../../../service_catalog/presentation/widgets/service_image.dart';
import '../providers/repair_categories_provider.dart';

/// Services section (separate from Products).
///  * Main Category        - the main service categories from the backend.
///  * All Service Categories - every main and sub category.
/// If the backend has no service categories yet, the original built-in repair
/// categories are shown instead so booking keeps working.
class RepairCategoryScreen extends ConsumerWidget {
  const RepairCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(serviceCategoryTreeProvider);

    final myBookings = IconButton(
      icon: const Icon(Icons.receipt_long_rounded),
      tooltip: 'My Bookings',
      onPressed: () => context.push(RouteNames.myRepairs),
    );

    return treeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Services'), actions: [myBookings]),
        body: const CardListSkeleton(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Services'), actions: [myBookings]),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(serviceCategoryTreeProvider),
        ),
      ),
      data: (roots) {
        if (roots.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Repair Services'),
              actions: [myBookings],
            ),
            body: const _LegacyCategoryList(),
          );
        }
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Services'),
              actions: [myBookings],
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
            body: TabBarView(
              children: [
                _MainServiceCategoryTab(roots: roots),
                _AllServiceCategoriesTab(roots: roots),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _openCategory(BuildContext context, ServiceCategoryItem c) =>
    context.push(RouteNames.serviceCategoryPath(c.id));

class _MainServiceCategoryTab extends StatelessWidget {
  const _MainServiceCategoryTab({required this.roots});

  final List<ServiceCategoryItem> roots;

  @override
  Widget build(BuildContext context) {
    // Tile height follows the user's font size so large-text phones fit.
    final scaler = MediaQuery.textScalerOf(context);
    final tileHeight = 16 + 56 + 8 + scaler.scale(12) * 1.5 * 3 + 8;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: tileHeight,
      ),
      itemCount: roots.length,
      itemBuilder: (context, index) {
        final c = roots[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openCategory(context, c),
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
                ServiceImage(imageUrl: c.imageUrl, width: 56, height: 56),
                const SizedBox(height: 8),
                Text(
                  c.name,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AllServiceCategoriesTab extends StatefulWidget {
  const _AllServiceCategoriesTab({required this.roots});

  final List<ServiceCategoryItem> roots;

  @override
  State<_AllServiceCategoriesTab> createState() =>
      _AllServiceCategoriesTabState();
}

class _AllServiceCategoriesTabState extends State<_AllServiceCategoriesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final rows = <({ServiceCategoryItem item, bool isChild})>[];
    for (final r in widget.roots) {
      rows.add((item: r, isChild: false));
      for (final c in r.children) {
        rows.add((item: c, isChild: true));
      }
    }
    final visible = q.isEmpty
        ? rows
        : rows.where((r) => r.item.name.toLowerCase().contains(q)).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Filter service categories',
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
                    final row = visible[index];
                    final c = row.item;
                    final indent = row.isChild && q.isEmpty ? 24.0 : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(left: indent),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openCategory(context, c),
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
                              ServiceImage(
                                imageUrl: c.imageUrl,
                                width: 44,
                                height: 44,
                                radius: 10,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  c.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: row.isChild
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
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

// ---------------------------------------------------------------------------
// Fallback: the original built-in repair categories (used only when the
// backend has no service categories yet).
// ---------------------------------------------------------------------------

class _LegacyCategoryList extends ConsumerWidget {
  const _LegacyCategoryList();

  IconData _iconFor(String iconName) => switch (iconName) {
    'electrical' => Icons.electrical_services_rounded,
    'cctv' => Icons.videocam_rounded,
    'tech' => Icons.computer_rounded,
    'plumbing' => Icons.plumbing_rounded,
    _ => Icons.build_rounded,
  };

  String? _assetFor(String iconName) => switch (iconName) {
    'electrical' => AssetConstants.techElectrical,
    'cctv' => AssetConstants.techCctv,
    'tech' => AssetConstants.techTech,
    'plumbing' => AssetConstants.techPlumbing,
    _ => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(repairCategoriesProvider);

    return categoriesState.when(
      data: (categories) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => context.push(
              RouteNames.repairBooking,
              extra: {'categoryId': cat.id, 'categoryName': cat.name},
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Row(
                children: [
                  _CategoryAvatar(
                    assetPath: _assetFor(cat.iconName),
                    fallbackIcon: _iconFor(cat.iconName),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
      loading: () => const CardListSkeleton(),
      error: (e, _) => AppErrorWidget(
        message: e.toString(),
        onRetry: () => ref.invalidate(repairCategoriesProvider),
      ),
    );
  }
}

/// Circular technician-in-action illustration loaded from a local SVG asset,
/// with a graceful icon fallback when no asset is available for the category.
class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.assetPath, required this.fallbackIcon});

  final String? assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (assetPath == null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primary.withAlpha(20),
          shape: BoxShape.circle,
        ),
        child: Icon(fallbackIcon, color: primary, size: 28),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withAlpha(40), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.asset(
          assetPath!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            color: primary.withAlpha(15),
            child: Icon(fallbackIcon, color: primary.withAlpha(120), size: 24),
          ),
        ),
      ),
    );
  }
}
