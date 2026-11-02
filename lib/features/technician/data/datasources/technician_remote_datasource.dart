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
    String? collectionMethod,
    String? amountInWords,
    String? collectionScreenshotPath,
  });

  /// Uploads an online-payment screenshot and returns its server path.
  Future<String> uploadPaymentProof(String filePath);
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
    String? collectionMethod,
    String? amountInWords,
    String? collectionScreenshotPath,
  }) async {
    try {
      final body = {
        'status': technicianJobStatusToApiString(status),
        if (serviceCharge != null) 'serviceCharge': serviceCharge,
        if (collectionMethod != null) 'collectionMethod': collectionMethod,
        if (amountInWords != null && amountInWords.isNotEmpty)
          'amountInWords': amountInWords,
        if (collectionScreenshotPath != null)
          'collectionScreenshotPath': collectionScreenshotPath,
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

  @override
  Future<String> uploadPaymentProof(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadPayment,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      return data['path'] as String? ?? '';
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final technicianRemoteDataSourceProvider =
    Provider<TechnicianRemoteDataSource>(
      (ref) => TechnicianRemoteDataSourceImpl(ref.watch(apiClientProvider)),
    );
