import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RatingInput extends StatelessWidget {
  const RatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  final double rating;
  final void Function(double) onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onRatingChanged(i + 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              i < rating.round()
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: 36,
              color: AppColors.starColor,
            ),
          ),
        );
      }),
    );
  }
}
