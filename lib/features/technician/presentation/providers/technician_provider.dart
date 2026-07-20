import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/technician_remote_datasource.dart';
import '../../domain/entities/technician_job_entity.dart';

/// The logged-in technician's assigned jobs, newest first.
final technicianJobsProvider =
    AsyncNotifierProvider<TechnicianJobsNotifier, List<TechnicianJobEntity>>(
      TechnicianJobsNotifier.new,
    );

class TechnicianJobsNotifier extends AsyncNotifier<List<TechnicianJobEntity>> {
  @override
  Future<List<TechnicianJobEntity>> build() async {
    final jobs = await ref
        .watch(technicianRemoteDataSourceProvider)
        .getMyJobs();
    final sorted = [...jobs]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final jobs = await ref
          .read(technicianRemoteDataSourceProvider)
          .getMyJobs();
      return [...jobs]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  /// Advances [jobId] to [status], optionally submitting the final service
  /// charge when completing the job, then refreshes the list.
  Future<bool> updateStatus(
    String jobId,
    TechnicianJobStatus status, {
    double? serviceCharge,
  }) async {
    try {
      await ref
          .read(technicianRemoteDataSourceProvider)
          .updateJobStatus(jobId, status, serviceCharge: serviceCharge);
      await refresh();
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update job $jobId',
        tag: 'TechnicianJobsNotifier',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }
}

/// A single job looked up from the already-loaded list, for the detail
/// screen — avoids a second network round trip after the list loads.
final technicianJobByIdProvider = Provider.family<TechnicianJobEntity?, String>(
  (ref, id) {
    final jobs = ref.watch(technicianJobsProvider).asData?.value ?? const [];
    for (final job in jobs) {
      if (job.id == id) return job;
    }
    return null;
  },
);
