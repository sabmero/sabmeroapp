import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/review_entity.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});
  final ReviewEntity review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: review.userAvatar ?? 'https://i.pravatar.cc/150?img=1',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const Spacer(),
                    Text(AppDateUtils.formatShort(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: AppColors.starColor,
                    );
                  }),
                ),
                if (review.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(review.comment!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
