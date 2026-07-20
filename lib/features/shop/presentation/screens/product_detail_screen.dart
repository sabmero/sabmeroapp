// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../../../core/router/route_names.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/utils/format_utils.dart';

// import '../../../../core/widgets/app_error_widget.dart';
// import '../../../../core/widgets/skeleton_loaders.dart';
// import '../../../cart/presentation/providers/cart_provider.dart';
// import '../../../reviews/presentation/widgets/review_list.dart';
// import '../../domain/entities/category_entity.dart';
// import '../providers/categories_provider.dart';
// import '../widgets/variant_selector.dart';

// class ProductDetailScreen extends ConsumerStatefulWidget {
//   const ProductDetailScreen({super.key, required this.productId});

//   final String productId;

//   @override
//   ConsumerState<ProductDetailScreen> createState() =>
//       _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
//   ProductVariantEntity? _selectedVariant;
//   int _quantity = 1;
//   int _selectedImageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final productState = ref.watch(productDetailProvider(widget.productId));

//     return productState.when(
//       data: (product) {
//         _selectedVariant ??= product.defaultVariant;
//         return Scaffold(
//           body: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 320,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: _ImageCarousel(
//                     imageUrls: product.imageUrls.isNotEmpty
//                         ? product.imageUrls
//                         : [product.primaryImage],
//                     selectedIndex: _selectedImageIndex,
//                     onImageSelected: (i) =>
//                         setState(() => _selectedImageIndex = i),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               product.name,
//                               style: Theme.of(context).textTheme.headlineSmall
//                                   ?.copyWith(fontWeight: FontWeight.w700),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star_rounded,
//                             size: 16,
//                             color: AppColors.starColor,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             product.vendorName,
//                             style: Theme.of(context).textTheme.bodySmall
//                                 ?.copyWith(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _StockIndicator(stock: product.stock, unit: product.unit),
//                       const SizedBox(height: 16),
//                       if (product.sizeOptions.isNotEmpty ||
//                           product.colorOptions.isNotEmpty) ...[
//                         Text(
//                           'Select Option',
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 10),
//                         VariantSelector(
//                           variants: product.variants,
//                           selectedVariant: _selectedVariant,
//                           onVariantSelected: (v) =>
//                               setState(() => _selectedVariant = v),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                       Row(
//                         children: [
//                           Text(
//                             FormatUtils.price(
//                               _selectedVariant?.price ?? product.basePrice,
//                             ),
//                             style: TextStyle(
//                               fontSize: 26,
//                               fontWeight: FontWeight.w800,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'Description',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.w600),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         product.description,
//                         style: Theme.of(
//                           context,
//                         ).textTheme.bodyMedium?.copyWith(height: 1.6),
//                       ),
//                       const SizedBox(height: 24),
//                       ReviewList.product(
//                         productId: product.id,
//                         productName: product.name,
//                       ),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: _AddToCartBar(
//             product: product,
//             selectedVariant: _selectedVariant,
//             quantity: _quantity,
//             onQuantityChanged: (q) => setState(() => _quantity = q),
//           ),
//         );
//       },
//       loading: () => const Scaffold(body: DetailSkeleton()),
//       error: (e, _) => Scaffold(
//         appBar: AppBar(),
//         body: AppErrorWidget(
//           message: e.toString(),
//           onRetry: () =>
//               ref.invalidate(productDetailProvider(widget.productId)),
//         ),
//       ),
//     );
//   }
// }

// class _StockIndicator extends StatelessWidget {
//   const _StockIndicator({required this.stock, required this.unit});

//   final int stock;
//   final String unit;

//   @override
//   Widget build(BuildContext context) {
//     final inStock = stock > 0;
//     final lowStock = inStock && stock <= 10;
//     final color = !inStock
//         ? AppColors.errorColor
//         : lowStock
//         ? AppColors.warningColor
//         : AppColors.successColor;
//     final label = !inStock
//         ? 'Out of Stock'
//         : lowStock
//         ? 'Only $stock left in stock'
//         : 'In Stock ($stock available)';

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//       decoration: BoxDecoration(
//         color: color.withAlpha(26),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             inStock ? Icons.inventory_2_outlined : Icons.remove_shopping_cart,
//             size: 15,
//             color: color,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.labelMedium?.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ImageCarousel extends StatelessWidget {
//   const _ImageCarousel({
//     required this.imageUrls,
//     required this.selectedIndex,
//     required this.onImageSelected,
//   });

//   final List<String> imageUrls;
//   final int selectedIndex;
//   final void Function(int) onImageSelected;

//   @override
//   Widget build(BuildContext context) {
//     if (imageUrls.isEmpty) {
//       return Container(
//         color: Theme.of(context).colorScheme.surfaceContainerHighest,
//         child: const Icon(Icons.image_outlined, size: 80),
//       );
//     }

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         CachedNetworkImage(
//           imageUrl: imageUrls[selectedIndex],
//           fit: BoxFit.cover,
//           placeholder: (_, _) => Container(
//             color: Theme.of(context).colorScheme.surfaceContainerHighest,
//           ),
//           errorWidget: (_, _, _) => const Icon(Icons.image_outlined, size: 80),
//         ),
//         if (imageUrls.length > 1)
//           Positioned(
//             bottom: 12,
//             left: 0,
//             right: 0,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 imageUrls.length,
//                 (i) => GestureDetector(
//                   onTap: () => onImageSelected(i),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     margin: const EdgeInsets.symmetric(horizontal: 3),
//                     width: i == selectedIndex ? 20 : 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: i == selectedIndex
//                           ? Colors.white
//                           : Colors.white.withAlpha(140),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }

// class _AddToCartBar extends ConsumerWidget {
//   const _AddToCartBar({
//     required this.product,
//     required this.selectedVariant,
//     required this.quantity,
//     required this.onQuantityChanged,
//   });

//   final ProductEntity product;
//   final ProductVariantEntity? selectedVariant;
//   final int quantity;
//   final void Function(int) onQuantityChanged;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final cartNotifier = ref.read(cartNotifierProvider.notifier);
//     // A product is purchasable when it has stock. The selected variant (real or
//     // the synthetic default) must also be in stock.
//     final variant = selectedVariant ?? product.defaultVariant;
//     final canAdd = product.stock > 0 && variant != null && variant.isInStock;

//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha(20),
//             blurRadius: 12,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Theme.of(context).colorScheme.outline),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove, size: 18),
//                   onPressed: quantity > 1
//                       ? () => onQuantityChanged(quantity - 1)
//                       : null,
//                 ),
//                 Text(
//                   '$quantity',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add, size: 18),
//                   onPressed: quantity < 99
//                       ? () => onQuantityChanged(quantity + 1)
//                       : null,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed: canAdd
//                   ? () {
//                       cartNotifier.addItem(
//                         product: product,
//                         variant: variant,
//                         quantity: quantity,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('${product.name} added to cart'),
//                           action: SnackBarAction(
//                             label: 'View Cart',
//                             onPressed: () => context.push(RouteNames.cart),
//                           ),
//                           duration: const Duration(seconds: 2),
//                         ),
//                       );
//                     }
//                   : null,
//               icon: const Icon(Icons.shopping_cart_outlined, size: 20),
//               label: Text(canAdd ? 'Add to Cart' : 'Out of Stock'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabmeroapp/reponsive.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../reviews/presentation/widgets/review_list.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/categories_provider.dart';
import '../widgets/variant_selector.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  ProductVariantEntity? _selectedVariant;
  int _quantity = 1;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productDetailProvider(widget.productId));

    return productState.when(
      data: (product) {
        _selectedVariant ??= product.defaultVariant;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ImageCarousel(
                    imageUrls: product.imageUrls.isNotEmpty
                        ? product.imageUrls
                        : [product.primaryImage],
                    selectedIndex: _selectedImageIndex,
                    onImageSelected: (i) =>
                        setState(() => _selectedImageIndex = i),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ResponsiveBody(
                  child: Padding(
                    padding: Responsive.pagePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.starColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              product.vendorName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _StockIndicator(
                          stock: product.stock,
                          unit: product.unit,
                        ),
                        const SizedBox(height: 16),
                        if (product.sizeOptions.isNotEmpty ||
                            product.colorOptions.isNotEmpty) ...[
                          Text(
                            'Select Option',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          VariantSelector(
                            variants: product.variants,
                            selectedVariant: _selectedVariant,
                            onVariantSelected: (v) =>
                                setState(() => _selectedVariant = v),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          children: [
                            Text(
                              FormatUtils.price(
                                _selectedVariant?.price ?? product.basePrice,
                              ),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 24),
                        ReviewList.product(
                          productId: product.id,
                          productName: product.name,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _AddToCartBar(
            product: product,
            selectedVariant: _selectedVariant,
            quantity: _quantity,
            onQuantityChanged: (q) => setState(() => _quantity = q),
          ),
        );
      },
      loading: () => const Scaffold(body: DetailSkeleton()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  const _StockIndicator({required this.stock, required this.unit});

  final int stock;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final inStock = stock > 0;
    final lowStock = inStock && stock <= 10;
    final color = !inStock
        ? AppColors.errorColor
        : lowStock
        ? AppColors.warningColor
        : AppColors.successColor;
    final label = !inStock
        ? 'Out of Stock'
        : lowStock
        ? 'Only $stock left in stock'
        : 'In Stock ($stock available)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.inventory_2_outlined : Icons.remove_shopping_cart,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.imageUrls,
    required this.selectedIndex,
    required this.onImageSelected,
  });

  final List<String> imageUrls;
  final int selectedIndex;
  final void Function(int) onImageSelected;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_outlined, size: 80),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrls[selectedIndex],
          fit: BoxFit.cover,
          placeholder: (_, _) => const Shimmer(
            child: SkeletonBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 0,
            ),
          ),
          errorWidget: (_, _, _) => const Icon(Icons.image_outlined, size: 80),
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (i) => GestureDetector(
                  onTap: () => onImageSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == selectedIndex ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == selectedIndex
                          ? Colors.white
                          : Colors.white.withAlpha(140),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddToCartBar extends ConsumerWidget {
  const _AddToCartBar({
    required this.product,
    required this.selectedVariant,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final ProductEntity product;
  final ProductVariantEntity? selectedVariant;
  final int quantity;
  final void Function(int) onQuantityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    // A product is purchasable when it has stock. The selected variant (real or
    // the synthetic default) must also be in stock.
    final variant = selectedVariant ?? product.defaultVariant;
    final canAdd = product.stock > 0 && variant != null && variant.isInStock;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: quantity > 1
                      ? () => onQuantityChanged(quantity - 1)
                      : null,
                ),
                Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: quantity < 99
                      ? () => onQuantityChanged(quantity + 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canAdd
                  ? () {
                      cartNotifier.addItem(
                        product: product,
                        variant: variant,
                        quantity: quantity,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          action: SnackBarAction(
                            label: 'View Cart',
                            onPressed: () => context.push(RouteNames.cart),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart_outlined, size: 18),
              label: Text(canAdd ? 'Add to Cart' : 'Out of Stock'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canAdd
                  ? () {
                      // Direct order: put the item in the cart and jump
                      // straight to checkout, skipping the cart screen.
                      cartNotifier.addItem(
                        product: product,
                        variant: variant,
                        quantity: quantity,
                      );
                      context.push(RouteNames.checkout);
                    }
                  : null,
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const Text('Order Now'),
            ),
          ),
        ],
      ),
    );
  }
}
