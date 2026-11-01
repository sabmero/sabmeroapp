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
import 'package:flutter/services.dart';
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
                actions: [
                  IconButton(
                    tooltip: 'Share',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black38,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _shareProduct(
                      context,
                      product,
                      _selectedVariant?.price ?? product.basePrice,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ImageCarousel(
                    imageUrls: product.imageUrls.isNotEmpty
                        ? product.imageUrls
                        : [product.primaryImage],
                    selectedIndex: _selectedImageIndex,
                    discountPercent: product.discountPercent,
                    onImageSelected: (i) =>
                        setState(() => _selectedImageIndex = i),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.15,
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
                                style: const TextStyle(
                                  fontSize: 19,
                                  height: 1.3,
                                  fontWeight: FontWeight.w700,
                                ),
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
                        // Price, old price and the discount badge on one line;
                        // the line shrinks to fit on narrow screens.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                FormatUtils.price(
                                  _selectedVariant?.price ?? product.basePrice,
                                ),
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              if (product.hasDiscount) ...[
                                const SizedBox(width: 10),
                                Text(
                                  FormatUtils.price(product.oldPrice!),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${product.discountPercent}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
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

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({
    required this.imageUrls,
    required this.selectedIndex,
    required this.onImageSelected,
    this.discountPercent = 0,
  });

  final List<String> imageUrls;
  final int selectedIndex;
  final int discountPercent;
  final void Function(int) onImageSelected;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _controller = PageController(
    initialPage: widget.selectedIndex,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_outlined, size: 80),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        PageView.builder(
          controller: _controller,
          itemCount: urls.length,
          onPageChanged: widget.onImageSelected,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) =>
                    _FullScreenGallery(imageUrls: urls, initialIndex: i),
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: urls[i],
              fit: BoxFit.contain,
              placeholder: (_, _) => const Shimmer(
                child: SkeletonBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
              errorWidget: (_, _, _) =>
                  const Icon(Icons.image_outlined, size: 80),
            ),
          ),
        ),
        if (widget.discountPercent > 0)
          Positioned(
            left: 12,
            bottom: 12,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${widget.discountPercent}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        if (urls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  urls.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == widget.selectedIndex ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == widget.selectedIndex
                          ? Colors.white
                          : Colors.white.withAlpha(140),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 2),
                      ],
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

/// Full-screen photo viewer: swipe between photos, pinch to zoom in/out,
/// double-tap to zoom in or reset.
class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _page = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1} / ${widget.imageUrls.length}'),
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.imageUrls.length,
        // Swiping between photos is paused while a photo is zoomed in, so
        // dragging moves the photo instead.
        physics: _zoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (i) => setState(() {
          _index = i;
          _zoomed = false;
        }),
        itemBuilder: (_, i) => _ZoomableImage(
          key: ValueKey(widget.imageUrls[i]),
          url: widget.imageUrls[i],
          onZoomChanged: (z) {
            if (z != _zoomed) setState(() => _zoomed = z);
          },
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    super.key,
    required this.url,
    required this.onZoomChanged,
  });

  final String url;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.01);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_controller.value.getMaxScaleOnAxis() > 1.01) {
      _controller.value = Matrix4.identity();
    } else {
      const scale = 2.5;
      final m = Matrix4.identity();
      m.setEntry(0, 0, scale);
      m.setEntry(1, 1, scale);
      m.setEntry(0, 3, -_tapPosition.dx * (scale - 1));
      m.setEntry(1, 3, -_tapPosition.dy * (scale - 1));
      _controller.value = m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _tapPosition = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

String _shareText(ProductEntity product, double price) {
  final b = StringBuffer()
    ..writeln(product.name)
    ..write('Price: ${FormatUtils.price(price)}');
  if (product.hasDiscount) {
    b.write(
      ' (was ${FormatUtils.price(product.oldPrice!)}, -${product.discountPercent}% OFF)',
    );
  }
  b.writeln();
  final img = product.imageUrls.isNotEmpty
      ? product.imageUrls.first
      : product.primaryImage;
  if (img.isNotEmpty) b.writeln(img);
  b.write('Get it on the SabMero app.');
  return b.toString();
}

/// Opens the phone's own share sheet (WhatsApp, Messenger, SMS, Viber,
/// email, ... whatever apps are installed). Uses a tiny native bridge in
/// MainActivity.kt, so no extra package is needed.
Future<void> _shareProduct(
  BuildContext context,
  ProductEntity product,
  double price,
) async {
  final text = _shareText(product, price);
  try {
    await const MethodChannel('sabmero/share').invokeMethod('shareText', {
      'text': text,
      'subject': product.name,
    });
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product details copied. Paste them in any app.'),
        ),
      );
    }
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
    final scheme = Theme.of(context).colorScheme;

    // Keep the bar readable on every phone: cap very large system font sizes
    // so button labels never wrap onto several lines.
    final mq = MediaQuery.of(context);
    final cappedScaler = mq.textScaler.clamp(maxScaleFactor: 1.15);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    const buttonPadding = EdgeInsets.symmetric(horizontal: 8);
    const buttonSize = Size(0, 50);
    const labelStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);

    return MediaQuery(
      data: mq.copyWith(textScaler: cappedScaler),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // One line: quantity stepper + Add to Cart + Order Now.
            // Button labels shrink to fit, so it works on every screen size.
            Row(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(11),
                        ),
                        onTap: quantity > 1
                            ? () => onQuantityChanged(quantity - 1)
                            : null,
                        child: SizedBox(
                          width: 32,
                          height: 50,
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: quantity > 1 ? null : scheme.outline,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 22),
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      InkWell(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(11),
                        ),
                        onTap: quantity < 99
                            ? () => onQuantityChanged(quantity + 1)
                            : null,
                        child: const SizedBox(
                          width: 32,
                          height: 50,
                          child: Icon(Icons.add, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: buttonSize,
                      padding: buttonPadding,
                      shape: buttonShape,
                      elevation: 4,
                      shadowColor: AppColors.accent.withAlpha(150),
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      disabledBackgroundColor: scheme.surfaceContainerHighest,
                    ),
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
                                  onPressed: () =>
                                      context.push(RouteNames.cart),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    child: _ButtonLabel(
                      icon: Icons.shopping_cart_outlined,
                      text: canAdd ? 'Add to Cart' : 'Out of Stock',
                      style: labelStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: canAdd
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2E5FA8), Color(0xFF16345F)],
                            )
                          : null,
                      boxShadow: canAdd
                          ? [
                              BoxShadow(
                                color: const Color(0xFF16345F).withAlpha(110),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: buttonSize,
                        padding: buttonPadding,
                        shape: buttonShape,
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: canAdd
                          ? () {
                              // Direct order: put the item in the cart and
                              // jump straight to checkout. Guests are asked to
                              // log in here (the router redirects), then
                              // continue.
                              cartNotifier.addItem(
                                product: product,
                                variant: variant,
                                quantity: quantity,
                              );
                              context.push(RouteNames.checkout);
                            }
                          : null,
                      child: const _ButtonLabel(
                        icon: Icons.flash_on_rounded,
                        text: 'Order Now',
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + single-line label that shrinks to fit instead of wrapping.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.icon,
    required this.text,
    required this.style,
  });

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(text, maxLines: 1, softWrap: false, style: style),
        ],
      ),
    );
  }
}
