import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/technician_job_entity.dart';
import '../models/technician_job_model.dart';

abstract class TechnicianRemoteDataSource {
  Future<List<TechnicianJobModel>> getMyJobs();
  Future<void> updateJobStatus(
    String jobId,
    TechnicianJobStatus status, {
    double? serviceCharge,
  });
}

class TechnicianRemoteDataSourceImpl implements TechnicianRemoteDataSource {
  TechnicianRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<TechnicianJobModel>> getMyJobs() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.technicianBookings,
      );
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => TechnicianJobModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> updateJobStatus(
    String jobId,
    TechnicianJobStatus status, {
    double? serviceCharge,
  }) async {
    try {
      final body = {
        'status': technicianJobStatusToApiString(status),
        if (serviceCharge != null) 'serviceCharge': serviceCharge,
      };
      final response = await _apiClient.dio.put(
        '${ApiConstants.bookings}/$jobId/status',
        data: body,
      );
      // This endpoint only returns { success, message } — no booking body —
      // so the caller re-fetches the job list to pick up the new status.
      _apiClient.unwrapMessage(response.data);
      AppLogger.info(
        'Job $jobId status -> ${body['status']}',
        tag: 'TechnicianRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final technicianRemoteDataSourceProvider =
    Provider<TechnicianRemoteDataSource>(
      (ref) => TechnicianRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );
