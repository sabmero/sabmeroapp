import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../service_catalog/data/models/service_catalog_models.dart';
import '../../../service_catalog/presentation/providers/service_catalog_provider.dart';
import '../../../service_catalog/presentation/widgets/service_image.dart';
import '../../../service_catalog/presentation/widgets/service_price_text.dart';
import 'section_header.dart';

/// Home section "Popular Services": featured services first, then the rest
/// (real data from the service catalog). Hidden when there are none.
class PopularServices extends ConsumerWidget {
  const PopularServices({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offers =
        ref.watch(serviceOffersProvider).asData?.value ??
        const <ServiceOffer>[];
    if (offers.isEmpty) return const SizedBox.shrink();

    final shown = [
      ...offers.where((o) => o.isFeatured),
      ...offers.where((o) => !o.isFeatured),
    ].take(6).toList();

    // Card height follows the user's font size so large-text phones fit.
    final scaler = MediaQuery.textScalerOf(context);
    final cardHeight =
        12 + 110 + 8 + scaler.scale(14) * 1.3 * 2 + 6 +
        scaler.scale(14) * 1.5 * 2 + 8 + 34 + 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Popular Services',
          actionLabel: 'See all',
          onAction: () => context.push(RouteNames.repairCategories),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: shown.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _ServiceTile(offer: shown[i]),
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.offer});

  final ServiceOffer offer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push(RouteNames.serviceDetail, extra: offer),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImage(
              imageUrl: offer.imageUrl,
              width: double.infinity,
              height: 110,
              radius: 10,
            ),
            const SizedBox(height: 8),
            Text(
              offer.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ServicePriceText(offer: offer),
            const Spacer(),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => context.push(
                  RouteNames.repairBooking,
                  extra: offer.bookingArgs,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
