import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rider/presentation/screens/rider_deliveries_screen.dart';
import '../../../technician/presentation/screens/technician_jobs_screen.dart';
import 'activity_hub_screen.dart';

/// Technicians and riders don't place orders/repair bookings themselves, so
/// their "Activity" tab shows the same job list as their Home tab (which
/// already includes completed jobs) instead of the customer order/repair
/// history hub.
class RoleActivityScreen extends ConsumerWidget {
  const RoleActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).asData?.value;

    return switch (user?.role) {
      UserRole.technician => const TechnicianJobsScreen(),
      UserRole.deliveryRider => const RiderDeliveriesScreen(),
      _ => const ActivityHubScreen(),
    };
  }
}
