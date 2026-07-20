import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.currentStatus});

  final OrderStatus currentStatus;

  static const _steps = [
    (OrderStatus.pending, 'Order Placed', Icons.receipt_outlined),
    (OrderStatus.confirmed, 'Confirmed', Icons.check_circle_outline),
    (OrderStatus.processing, 'Processing', Icons.inventory_2_outlined),
    (OrderStatus.shipped, 'Shipped', Icons.local_shipping_outlined),
    (OrderStatus.delivered, 'Delivered', Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentStatus == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorColor.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.errorColor),
            const SizedBox(width: 12),
            Text(
              'Order Cancelled',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.errorColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    final currentIndex = _steps.indexWhere((s) => s.$1 == currentStatus);

    return Column(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentIndex;
          return SizedBox(
            height: 32,
            child: Row(
              children: [
                const SizedBox(width: 20),
                SizedBox(
                  width: 2,
                  height: 32,
                  child: ColoredBox(
                    color: isDone
                        ? AppColors.successColor
                        : Theme.of(context).colorScheme.outline,
                  ),
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
                color: isDone || isCurrent
                    ? isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : AppColors.successColor
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
