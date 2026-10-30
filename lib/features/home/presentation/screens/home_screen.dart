import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../shop/presentation/providers/categories_provider.dart';
import '../../../shop/presentation/widgets/product_card.dart';
import '../widgets/category_chip_list.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/repair_section_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shop_section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openAllProducts(BuildContext context) {
    context.push(
      RouteNames.productList,
      extra: {'categoryId': '', 'categoryName': 'All Products'},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).asData?.value;
    final cartCount = ref.watch(
      cartNotifierProvider.select((s) => s.itemCount),
    );
    final featuredState = ref.watch(productsNotifierProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Sab'),
                  TextSpan(
                    text: 'Mero',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            if (user != null)
              Text(
                'Hi, ${user.name.split(' ').first}!',
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: () => context.push(RouteNames.cart),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: AppColors.onAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(categoriesNotifierProvider.notifier).refresh(),
            ref.read(productsNotifierProvider(null).notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HomeSearchBar(onTap: () => _openAllProducts(context)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Two clearly separate entry points: products and services.
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: ShopSectionCard()),
                      SizedBox(width: 12),
                      Expanded(child: RepairSectionCard()),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Shop by Main Category',
                actionLabel: 'View All',
                onAction: () => context.push(RouteNames.categoryList),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 6)),
            const SliverToBoxAdapter(child: CategoryChipList()),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Featured Products',
                actionLabel: 'See all',
                onAction: () => _openAllProducts(context),
              ),
            ),

            featuredState.when(
              data: (state) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = state.items[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push(
                        RouteNames.productDetail.replaceFirst(
                          ':id',
                          product.id,
                        ),
                      ),
                    );
                  }, childCount: state.items.take(6).length),
                ),
              ),
              loading: () =>
                  SliverToBoxAdapter(child: ProductGridSkeleton(itemCount: 6)),
              error: (e, _) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }
}
