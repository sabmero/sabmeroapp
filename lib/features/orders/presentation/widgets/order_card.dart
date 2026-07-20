import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/format_utils.dart';
import '../../domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  Color _statusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppColors.warningColor,
      OrderStatus.confirmed => AppColors.statusConfirmed,
      OrderStatus.processing => AppColors.statusProcessing,
      OrderStatus.shipped => AppColors.statusShipped,
      OrderStatus.delivered => AppColors.successColor,
      OrderStatus.cancelled => AppColors.errorColor,
    };
  }

  String get _shortOrderId {
    final id = order.id;
    return id.length > 4 ? id.substring(4).toUpperCase() : id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Text(
                //   'Order #${order.id.substring(4).toUpperCase()}',
                //   style: Theme.of(
                //     context,
                //   ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                // ),
                Text(
                  'Order #$_shortOrderId',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.items.map((i) => i.productName).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Divider(height: 20),
            Row(
              children: [
                Text(
                  AppDateUtils.formatDate(order.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  FormatUtils.price(order.total),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
