import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/service_catalog_remote_datasource.dart';
import '../../data/models/service_catalog_models.dart';

/// Active main service categories (each with its sub-categories).
final serviceCategoryTreeProvider = FutureProvider<List<ServiceCategoryItem>>((
  ref,
) async {
  final all = await ref.watch(serviceCatalogDataSourceProvider).fetchCategories();
  final roots = all.toList()
    ..sort((a, b) {
      final c = a.sortOrder.compareTo(b.sortOrder);
      return c != 0 ? c : a.name.compareTo(b.name);
    });
  return roots;
});

/// Bookable services and packages (products are never part of this).
final serviceOffersProvider = FutureProvider<List<ServiceOffer>>((ref) async {
  final ds = ref.watch(serviceCatalogDataSourceProvider);
  final servicesFuture = ds.fetchServices();
  final packagesFuture = ds.fetchPackages();
  final services = await servicesFuture;
  final packages = await packagesFuture;
  return [...packages, ...services];
});

/// Finds a category (main or sub) by id in the tree.
ServiceCategoryItem? findServiceCategory(
  List<ServiceCategoryItem> roots,
  int id,
) {
  for (final r in roots) {
    if (r.id == id) return r;
    for (final c in r.children) {
      if (c.id == id) return c;
    }
  }
  return null;
}
