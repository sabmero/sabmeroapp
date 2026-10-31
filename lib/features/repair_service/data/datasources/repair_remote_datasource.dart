import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/repair_category_model.dart';

abstract class RepairRemoteDataSource {
  Future<List<RepairCategoryModel>> getRepairCategories();
  Future<RepairBookingModel> createRepairBooking({
    required String categoryId,
    required String categoryName,
    required String address,
    required DateTime scheduledDate,
    required String timeSlot,
    String? problemDescription,
    List<String> damagePhotoUrls,
    double? latitude,
    double? longitude,
    String paymentMethod,
    String? paymentScreenshotPath,
  });
  Future<List<RepairBookingModel>> getRepairBookings();
  Future<void> cancelBooking(String bookingId);
  Future<String> uploadDamagePhoto(String filePath);
  Future<String> uploadPaymentScreenshot(String filePath);
  Future<RepairBookingModel> trackRepairStatus(String bookingId);
}

class RepairRemoteDataSourceImpl implements RepairRemoteDataSource {
  RepairRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  // The backend recognises three service types. Repair categories are a
  // static client-side concept; this maps a category to the API serviceType.
  static const Map<String, String> _serviceTypeByCategory = {
    'rep_electrical': 'Electrical',
    'rep_cctv': 'CCTV',
    'rep_tech': 'Tech',
    'rep_plumbing': 'Electrical',
  };

  // Static catalogue — there is no repair-category API endpoint.
  static const List<RepairCategoryModel> _categories = [
    RepairCategoryModel(
      id: 'rep_electrical',
      name: 'Electrical Repair',
      description:
          'Wiring, switches, sockets, fans, lights, circuit breakers, and all electrical work.',
      iconName: 'electrical',
      baseCharge: 500,
    ),
    RepairCategoryModel(
      id: 'rep_cctv',
      name: 'CCTV Services',
      description:
          'Installation, maintenance, and repair of CCTV cameras and security systems.',
      iconName: 'cctv',
      baseCharge: 800,
    ),
    RepairCategoryModel(
      id: 'rep_tech',
      name: 'Tech Repair',
      description:
          'Computer, laptop, mobile phone, printer, and smart TV repair services.',
      iconName: 'tech',
      baseCharge: 600,
    ),
    RepairCategoryModel(
      id: 'rep_plumbing',
      name: 'Plumbing',
      description:
          'Pipe repair, tap replacement, water tank installation, and drain cleaning.',
      iconName: 'plumbing',
      baseCharge: 400,
    ),
  ];

  static String _serviceTypeFromName(String name) {
    final n = name.trim();
    if (n.isEmpty) return 'Tech';
    return n.length > 50 ? n.substring(0, 50) : n;
  }

  @override
  Future<List<RepairCategoryModel>> getRepairCategories() async {
    return _categories;
  }

  @override
  Future<RepairBookingModel> createRepairBooking({
    required String categoryId,
    required String categoryName,
    required String address,
    required DateTime scheduledDate,
    required String timeSlot,
    String? problemDescription,
    List<String> damagePhotoUrls = const [],
    double? latitude,
    double? longitude,
    String paymentMethod = 'Cash',
    String? paymentScreenshotPath,
  }) async {
    try {
      final body = {
        // Built-in categories keep their original mapping. Services chosen
        // from the admin catalog send their own name (the backend column
        // holds at most 50 characters).
        'serviceType':
            _serviceTypeByCategory[categoryId] ?? _serviceTypeFromName(categoryName),
        'bookingDate': scheduledDate.toUtc().toIso8601String(),
        'timeSlot': timeSlot,
        'latitude': latitude ?? 0,
        'longitude': longitude ?? 0,
        'serviceAddress': address,
        if (damagePhotoUrls.isNotEmpty)
          'damageImagePath': damagePhotoUrls.first,
        // Backend accepts "Cash" | "QR".
        'paymentMethod': paymentMethod,
        // Required by the backend when paymentMethod == "QR".
        if (paymentScreenshotPath != null && paymentScreenshotPath.isNotEmpty)
          'paymentScreenshotPath': paymentScreenshotPath,
      };
      final response = await _apiClient.dio.post(
        ApiConstants.bookings,
        data: body,
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info(
        'Booking created: ${data['id']}',
        tag: 'RepairRemoteDataSource',
      );
      return RepairBookingModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<RepairBookingModel>> getRepairBookings() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.myBookings);
      final list = _apiClient.unwrapList(response.data);
      return list
          .map((e) => RepairBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.bookings}/$bookingId/cancel',
      );
      // Throws a ServerException with the backend message when success == false.
      _apiClient.unwrapMessage(response.data);
      AppLogger.info(
        'Booking cancelled: $bookingId',
        tag: 'RepairRemoteDataSource',
      );
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> uploadDamagePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadDamage,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      final path = data['path'] as String? ?? '';
      AppLogger.info(
        'Damage photo uploaded: $path',
        tag: 'RepairRemoteDataSource',
      );
      return path;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> uploadPaymentScreenshot(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.uploadPayment,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      final path = data['path'] as String? ?? '';
      AppLogger.info(
        'Payment screenshot uploaded: $path',
        tag: 'RepairRemoteDataSource',
      );
      return path;
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<RepairBookingModel> trackRepairStatus(String bookingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.bookings}/$bookingId',
      );
      final data = _apiClient.unwrapObject(response.data);
      return RepairBookingModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }
}

final repairRemoteDataSourceProvider = Provider<RepairRemoteDataSource>(
  (ref) => RepairRemoteDataSourceImpl(ref.watch(apiClientProvider)),
);
