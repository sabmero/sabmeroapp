import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../service_catalog/data/models/service_catalog_models.dart';
import '../../../service_catalog/presentation/providers/service_catalog_provider.dart';
import '../../../shop/presentation/providers/categories_provider.dart';

/// One photo in the offers row (a discounted product or service).
class _OfferItem {
  const _OfferItem({
    required this.imageUrl,
    required this.discountPercent,
    required this.isService,
    required this.open,
  });

  final String imageUrl;
  final int discountPercent;
  final bool isService;
  final void Function(BuildContext context) open;
}

/// Sliding row of product photos that are on discount, each with a red
/// "40% OFF" badge. Hidden completely when there are no offers.
class OffersBanner extends ConsumerStatefulWidget {
  const OffersBanner({super.key});

  @override
  ConsumerState<OffersBanner> createState() => _OffersBannerState();
}

class _OffersBannerState extends ConsumerState<OffersBanner> {
  // Two photos side by side; the next one peeks in at the edge.
  final _controller = PageController(viewportFraction: 0.48);
  Timer? _timer;
  int _page = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _count < 3 || !_controller.hasClients) return;
      _page = (_page + 1) % (_count - 1);
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref
            .watch(productsNotifierProvider(null))
            .asData
            ?.value
            .items
            .where((p) => p.hasDiscount && p.stock > 0)
            .toList() ??
        const [];
    final serviceOffers = ref
            .watch(serviceOffersProvider)
            .asData
            ?.value
            .where((o) => o.hasDiscount && o.imageUrl.isNotEmpty)
            .toList() ??
        const <ServiceOffer>[];

    // Products first, then services; both open their own detail page.
    final items = <_OfferItem>[
      for (final p in products)
        _OfferItem(
          imageUrl: p.primaryImage,
          discountPercent: p.discountPercent,
          isService: false,
          open: (ctx) => ctx.push(
            RouteNames.productDetail.replaceFirst(':id', p.id),
          ),
        ),
      for (final o in serviceOffers)
        _OfferItem(
          imageUrl: o.imageUrl,
          discountPercent: o.discountPercent > 0
              ? o.discountPercent
              : (((o.oldPrice! - o.price) / o.oldPrice!) * 100).round(),
          isService: true,
          open: (ctx) => ctx.push(RouteNames.serviceDetail, extra: o),
        ),
    ].take(10).toList();
    _count = items.length;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // Photos are square, as wide as half the screen.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxWidth * 0.48;
          return SizedBox(
            height: height,
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              itemCount: items.length,
              onPageChanged: (i) => _page = i,
              itemBuilder: (context, i) {
                final p = items[i];
                return Padding(
                  padding: EdgeInsets.fromLTRB(i == 0 ? 16 : 4, 0, 4, 0),
                  child: GestureDetector(
                    onTap: () => p.open(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const ColoredBox(color: Colors.white),
                          CachedNetworkImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.image_outlined, size: 40),
                          ),
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${p.discountPercent}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          if (p.isService)
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A3C6E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Service',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
