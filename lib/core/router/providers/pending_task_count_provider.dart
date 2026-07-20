import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/rider/domain/entities/rider_delivery_entity.dart';
import '../../../features/rider/presentation/providers/rider_provider.dart';
import '../../../features/technician/domain/entities/technician_job_entity.dart';
import '../../../features/technician/presentation/providers/technician_provider.dart';

final pendingTaskCountProvider = Provider<int>((ref) {
  final role = ref.watch(authNotifierProvider).asData?.value?.role;

  if (role == UserRole.technician) {
    final jobs = ref.watch(technicianJobsProvider).asData?.value ?? const [];
    return jobs.where((j) => j.status == TechnicianJobStatus.approved).length;
  }
  if (role == UserRole.deliveryRider) {
    final deliveries =
        ref.watch(riderDeliveriesProvider).asData?.value ?? const [];
    return deliveries
        .where((d) => d.status == RiderDeliveryStatus.dispatched)
        .length;
  }
  return 0;
});
