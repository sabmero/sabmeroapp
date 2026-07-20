// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';
// import '../../../../core/widgets/app_error_widget.dart';
// import '../../../../core/widgets/app_loader.dart';
// import '../providers/categories_provider.dart';

// class CategoryListScreen extends ConsumerWidget {
//   const CategoryListScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final categoriesState = ref.watch(categoriesNotifierProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Categories')),
//       body: categoriesState.when(
//         data: (categories) => GridView.builder(
//           padding: const EdgeInsets.all(16),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 12,
//             mainAxisSpacing: 12,
//             childAspectRatio: 1.1,
//           ),
//           itemCount: categories.length,
//           itemBuilder: (context, index) {
//             final category = categories[index];
//             return GestureDetector(
//               onTap: () => context.push(
//                 RouteNames.productList,
//                 extra: {
//                   'categoryId': category.id,
//                   'categoryName': category.name,
//                 },
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withAlpha(12),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(40),
//                       child: CachedNetworkImage(
//                         imageUrl: category.imageUrl,
//                         width: 64,
//                         height: 64,
//                         fit: BoxFit.cover,
//                         placeholder: (_, _) => Container(
//                           width: 64,
//                           height: 64,
//                           color: Theme.of(
//                             context,
//                           ).colorScheme.surfaceContainerHighest,
//                         ),
//                         errorWidget: (_, _, _) =>
//                             const Icon(Icons.category_outlined, size: 40),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       category.name,
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '${category.productCount} items',
//                       style: Theme.of(context).textTheme.bodySmall,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//         loading: () => const AppLoader(),
//         error: (e, _) => AppErrorWidget(
//           message: e.toString(),
//           onRetry: () => ref.invalidate(categoriesNotifierProvider),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/skeleton.dart';
import '../providers/categories_provider.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: categoriesState.when(
        data: (categories) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () => context.push(
                RouteNames.productList,
                extra: {
                  'categoryId': category.id,
                  'categoryName': category.name,
                },
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const Shimmer(
                          child: SkeletonBox(
                            width: 64,
                            height: 64,
                            borderRadius: 40,
                          ),
                        ),
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.category_outlined, size: 40),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.productCount} items',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const AppLoader(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(categoriesNotifierProvider),
        ),
      ),
    );
  }
}
