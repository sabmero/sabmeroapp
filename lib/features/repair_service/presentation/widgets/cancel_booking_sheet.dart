import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/repair_categories_provider.dart';

/// Shows a confirmation dialog and, if confirmed, cancels [bookingId].
///
/// Returns `true` when the booking was successfully cancelled so the caller can
/// react (e.g. pop the screen). Shows its own snackbars for success/failure.
Future<bool> confirmAndCancelBooking({
  required BuildContext context,
  required WidgetRef ref,
  required String bookingId,
  required String serviceName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Cancel booking?'),
      content: Text(
        'Are you sure you want to cancel your $serviceName booking? '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Keep booking'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.errorColor),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Yes, cancel'),
        ),
      ],
    ),
  );

  if (confirmed != true) return false;
  if (!context.mounted) return false;

  final result = await ref
      .read(repairCancelNotifierProvider.notifier)
      .cancel(bookingId);

  if (!context.mounted) return result.success;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.message),
      backgroundColor: result.success
          ? AppColors.successColor
          : AppColors.errorColor,
    ),
  );
  return result.success;
}
