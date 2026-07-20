import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rider/presentation/screens/rider_deliveries_screen.dart';
import '../../../technician/presentation/screens/technician_jobs_screen.dart';
import 'home_screen.dart';

/// The "Home" tab shows different content depending on who's logged in:
/// customers (and vendors/admins) see the shop; technicians see their
/// assigned jobs; riders see their assigned deliveries.
class RoleHomeScreen extends ConsumerWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).asData?.value;

    return switch (user?.role) {
      UserRole.technician => const TechnicianJobsScreen(),
      UserRole.deliveryRider => const RiderDeliveriesScreen(),
      _ => const HomeScreen(),
    };
  }
}
