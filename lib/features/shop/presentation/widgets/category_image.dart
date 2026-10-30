import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton.dart';

/// Rounded category picture loaded from the backend image URL, with a shimmer
/// placeholder and an icon fallback when the category has no image.
class CategoryImage extends StatelessWidget {
  const CategoryImage({
    super.key,
    required this.imageUrl,
    this.size = 56,
    this.radius = 14,
  });

  final String imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget fallback() => Container(
      width: size,
      height: size,
      color: primary.withAlpha(20),
      child: Icon(Icons.category_outlined, color: primary, size: size * 0.5),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageUrl.isEmpty
          ? fallback()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, _) => Shimmer(
                child: SkeletonBox(
                  width: size,
                  height: size,
                  borderRadius: radius,
                ),
              ),
              errorWidget: (_, _, _) => fallback(),
            ),
    );
  }
}
