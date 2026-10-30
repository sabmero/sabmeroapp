import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';

/// "Book Services" entry card (orange). Opens the service/repair screen.
class RepairSectionCard extends StatelessWidget {
  const RepairSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.repairCategories),
      child: Container(
        constraints: const BoxConstraints(minHeight: 128),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onAccent.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.build_rounded,
                color: AppColors.onAccent,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Book Services',
              style: TextStyle(
                color: AppColors.onAccent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Find a Technician',
              style: TextStyle(
                color: AppColors.onAccent.withAlpha(210),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
