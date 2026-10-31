import 'package:flutter/material.dart';
import '../../../../core/utils/format_utils.dart';
import '../../data/models/service_catalog_models.dart';

/// Price line: offer price, struck-through regular price and discount badge.
/// Shows "Price on request" when the admin has not set a price.
class ServicePriceText extends StatelessWidget {
  const ServicePriceText({super.key, required this.offer, this.large = false});

  final ServiceOffer offer;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (!offer.hasPrice) {
      return Text(
        'Price on request',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.hintColor,
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 2,
      children: [
        Text(
          FormatUtils.price(offer.price),
          style: (large ? theme.textTheme.titleLarge : theme.textTheme.titleSmall)
              ?.copyWith(fontWeight: FontWeight.w800, color: primary),
        ),
        if (offer.hasDiscount)
          Text(
            FormatUtils.price(offer.oldPrice!),
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.hintColor,
            ),
          ),
        if (offer.hasDiscount && offer.discountPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '-${offer.discountPercent}%',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
