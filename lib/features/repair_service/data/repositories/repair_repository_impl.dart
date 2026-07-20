import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/repair_category_entity.dart';
import '../../domain/repositories/repair_repository.dart';
import '../datasources/repair_remote_datasource.dart';

class RepairRepositoryImpl implements RepairRepository {
  final RepairRemoteDataSource remoteDataSource;
  const RepairRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RepairCategoryEntity>> getRepairCategories() async {
    try {
      return await remoteDataSource.getRepairCategories();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<RepairBookingEntity> createRepairBooking({
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
      return await remoteDataSource.createRepairBooking(
        categoryId: categoryId,
        categoryName: categoryName,
        address: address,
        scheduledDate: scheduledDate,
        timeSlot: timeSlot,
        problemDescription: problemDescription,
        damagePhotoUrls: damagePhotoUrls,
        latitude: latitude,
        longitude: longitude,
        paymentMethod: paymentMethod,
        paymentScreenshotPath: paymentScreenshotPath,
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      return await remoteDataSource.cancelBooking(bookingId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<RepairBookingEntity>> getRepairBookings() async {
    try {
      final bookings = await remoteDataSource.getRepairBookings();
      // Return a List<RepairBookingEntity> (not the concrete model subtype list)
      // so callers' firstWhere/orElse type-check against the entity type.
      return List<RepairBookingEntity>.from(bookings);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String> uploadDamagePhoto(String filePath) async {
    try {
      return await remoteDataSource.uploadDamagePhoto(filePath);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String> uploadPaymentScreenshot(String filePath) async {
    try {
      return await remoteDataSource.uploadPaymentScreenshot(filePath);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<RepairBookingEntity> trackRepairStatus(String bookingId) async {
    try {
      return await remoteDataSource.trackRepairStatus(bookingId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}

final repairRepositoryProvider = Provider<RepairRepository>((ref) {
  return RepairRepositoryImpl(ref.watch(repairRemoteDataSourceProvider));
});
