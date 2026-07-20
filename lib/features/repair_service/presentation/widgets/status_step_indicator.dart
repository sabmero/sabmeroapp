import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/repair_category_entity.dart';

class StatusStepIndicator extends StatelessWidget {
  const StatusStepIndicator({super.key, required this.currentStatus});
  final RepairStatus currentStatus;

  static const _steps = [
    (RepairStatus.pending, 'Booking Received', Icons.receipt_outlined),
    (RepairStatus.processing, 'Assigned to Technician', Icons.person_outlined),
    (RepairStatus.onTheWay, 'On the Way', Icons.directions_run_rounded),
    (RepairStatus.completed, 'Service Completed', Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == RepairStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.errorColor),
            SizedBox(width: 12),
            Text('Booking Cancelled',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.errorColor)),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexWhere((s) => s.$1 == currentStatus);

    return Column(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isDone = i ~/ 2 < currentIndex;
          return SizedBox(
            height: 28,
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  width: 2,
                  height: 28,
                  color: isDone
                      ? AppColors.successColor
                      : Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final step = _steps[stepIndex];
        final isDone = stepIndex < currentIndex;
        final isCurrent = stepIndex == currentIndex;
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.successColor
                    : isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDone ? Icons.check_rounded : step.$3,
                size: 20,
                color: isDone || isCurrent
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              step.$2,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
            ),
          ],
        );
      }),
    );
  }
}
