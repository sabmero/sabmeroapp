import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  IconData _iconFor(NotificationType type) => switch (type) {
        NotificationType.order => Icons.receipt_long_outlined,
        NotificationType.repair => Icons.build_outlined,
        NotificationType.promo => Icons.local_offer_outlined,
        NotificationType.system => Icons.info_outline,
      };

  Color _colorFor(NotificationType type, BuildContext context) => switch (type) {
        NotificationType.order => Theme.of(context).colorScheme.primary,
        NotificationType.repair => AppColors.statusProcessing,
        NotificationType.promo => AppColors.warningColor,
        NotificationType.system => Theme.of(context).colorScheme.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorFor(notification.type, context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : Theme.of(context).colorScheme.primary.withAlpha(8),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconFor(notification.type),
                  color: typeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.timeAgo(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
