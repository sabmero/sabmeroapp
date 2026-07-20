// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';
// import '../../../../core/widgets/app_error_widget.dart';
// import '../../../../core/widgets/skeleton_loaders.dart';
// import '../providers/repair_categories_provider.dart';

// class RepairCategoryScreen extends ConsumerWidget {
//   const RepairCategoryScreen({super.key});

//   IconData _iconFor(String iconName) => switch (iconName) {
//     'electrical' => Icons.electrical_services_rounded,
//     'cctv' => Icons.videocam_rounded,
//     'tech' => Icons.computer_rounded,
//     'plumbing' => Icons.plumbing_rounded,
//     _ => Icons.build_rounded,
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesState = ref.watch(repairCategoriesProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Repair Services'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.receipt_long_rounded),
//             tooltip: 'My Bookings',
//             onPressed: () => context.push(RouteNames.myRepairs),
//           ),
//         ],
//       ),
//       body: categoriesState.when(
//         data: (categories) => ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final cat = categories[index];
//             return GestureDetector(
//               onTap: () => context.push(
//                 RouteNames.repairBooking,
//                 extra: {'categoryId': cat.id, 'categoryName': cat.name},
//               ),
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(10),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 56,
//                       height: 56,
//                       decoration: BoxDecoration(
//                         color: Theme.of(
//                           context,
//                         ).colorScheme.primary.withAlpha(20),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         _iconFor(cat.iconName),
//                         color: Theme.of(context).colorScheme.primary,
//                         size: 28,
//                       ),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             cat.name,
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             cat.description,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Icon(Icons.chevron_right_rounded),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         loading: () => const CardListSkeleton(),
//         error: (e, _) => AppErrorWidget(
//           message: e.toString(),
//           onRetry: () => ref.invalidate(repairCategoriesProvider),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/core/constants/asset_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../providers/repair_categories_provider.dart';

class RepairCategoryScreen extends ConsumerWidget {
  const RepairCategoryScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded),
            tooltip: 'My Bookings',
            onPressed: () => context.push(RouteNames.myRepairs),
          ),
        ],
      ),
      body: categoriesState.when(
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
