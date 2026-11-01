import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../shop/presentation/providers/categories_provider.dart';

/// Auto-sliding strip of products that currently have a discount.
/// Hidden completely when there are no offers.
class OffersBanner extends ConsumerStatefulWidget {
  const OffersBanner({super.key});

  @override
  ConsumerState<OffersBanner> createState() => _OffersBannerState();
}

class _OffersBannerState extends ConsumerState<OffersBanner> {
  final _controller = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _page = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _count < 2 || !_controller.hasClients) return;
      _page = (_page + 1) % _count;
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
    final items = ref
            .watch(productsNotifierProvider(null))
            .asData
            ?.value
            .items
            .where((p) => p.hasDiscount && p.stock > 0)
            .take(8)
            .toList() ??
        const [];
    _count = items.length;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      // Text size is capped here so a large system font can't overflow the card.
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _controller,
          itemCount: items.length,
          onPageChanged: (i) => _page = i,
          itemBuilder: (context, i) {
            final p = items[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(
                  RouteNames.productDetail.replaceFirst(':id', p.id),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${p.discountPercent}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                FormatUtils.price(p.basePrice),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                FormatUtils.price(p.oldPrice!),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(16),
                        ),
                        child: Container(
                          width: 130,
                          height: double.infinity,
                          color: Colors.white,
                          child: CachedNetworkImage(
                            imageUrl: p.primaryImage,
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) =>
                                const Icon(Icons.image_outlined, size: 40),
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
      ),
      ),
    );
  }
}
