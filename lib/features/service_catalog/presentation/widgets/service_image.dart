import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/skeleton.dart';

/// Rounded image from the backend with a shimmer placeholder and an icon
/// fallback when there is no image.
class ServiceImage extends StatelessWidget {
  const ServiceImage({
    super.key,
    required this.imageUrl,
    this.width = 56,
    this.height = 56,
    this.radius = 14,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double width;
  final double height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    Widget fallback() => Container(
      width: width,
      height: height,
      color: primary.withAlpha(20),
      child: Icon(
        Icons.build_circle_outlined,
        color: primary,
        size: (width < height ? width : height) * 0.5,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: imageUrl.isEmpty
          ? fallback()
          : CachedNetworkImage(
              imageUrl: imageUrl,
              width: width,
              height: height,
              fit: fit,
              placeholder: (_, _) => Shimmer(
                child: SkeletonBox(
                  width: width,
                  height: height,
                  borderRadius: radius,
                ),
              ),
              errorWidget: (_, _, _) => fallback(),
            ),
    );
  }
}
