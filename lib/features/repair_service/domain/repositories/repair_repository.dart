import '../entities/repair_category_entity.dart';
import '../../../../core/usecases/usecase.dart';

abstract class RepairRepository {
  Future<List<RepairCategoryEntity>> getRepairCategories();
  Future<RepairBookingEntity> createRepairBooking({
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
  Future<List<RepairBookingEntity>> getRepairBookings();
  Future<void> cancelBooking(String bookingId);
  Future<String> uploadDamagePhoto(String filePath);
  Future<String> uploadPaymentScreenshot(String filePath);
  Future<RepairBookingEntity> trackRepairStatus(String bookingId);
}

class GetRepairCategoriesUseCase
    implements UseCase<List<RepairCategoryEntity>, NoParams> {
  final RepairRepository repository;
  const GetRepairCategoriesUseCase(this.repository);
  @override
  Future<List<RepairCategoryEntity>> call(NoParams params) =>
      repository.getRepairCategories();
}

class CreateRepairBookingParams {
  final String categoryId;
  final String categoryName;
  final String address;
  final DateTime scheduledDate;
  final String timeSlot;
  final String? problemDescription;
  final List<String> damagePhotoUrls;
  final double? latitude;
  final double? longitude;
  final String paymentMethod;
  final String? paymentScreenshotPath;

  const CreateRepairBookingParams({
    required this.categoryId,
    required this.categoryName,
    required this.address,
    required this.scheduledDate,
    required this.timeSlot,
    this.problemDescription,
    this.damagePhotoUrls = const [],
    this.latitude,
    this.longitude,
    this.paymentMethod = 'Cash',
    this.paymentScreenshotPath,
  });
}

class CreateRepairBookingUseCase
    implements UseCase<RepairBookingEntity, CreateRepairBookingParams> {
  final RepairRepository repository;
  const CreateRepairBookingUseCase(this.repository);
  @override
  Future<RepairBookingEntity> call(CreateRepairBookingParams params) =>
      repository.createRepairBooking(
        categoryId: params.categoryId,
        categoryName: params.categoryName,
        address: params.address,
        scheduledDate: params.scheduledDate,
        timeSlot: params.timeSlot,
        problemDescription: params.problemDescription,
        damagePhotoUrls: params.damagePhotoUrls,
        latitude: params.latitude,
        longitude: params.longitude,
        paymentMethod: params.paymentMethod,
        paymentScreenshotPath: params.paymentScreenshotPath,
      );
}

class CancelRepairBookingUseCase implements UseCase<void, String> {
  final RepairRepository repository;
  const CancelRepairBookingUseCase(this.repository);
  @override
  Future<void> call(String bookingId) => repository.cancelBooking(bookingId);
}

class GetRepairBookingsUseCase
    implements UseCase<List<RepairBookingEntity>, NoParams> {
  final RepairRepository repository;
  const GetRepairBookingsUseCase(this.repository);
  @override
  Future<List<RepairBookingEntity>> call(NoParams params) =>
      repository.getRepairBookings();
}

class TrackRepairStatusUseCase implements UseCase<RepairBookingEntity, String> {
  final RepairRepository repository;
  const TrackRepairStatusUseCase(this.repository);
  @override
  Future<RepairBookingEntity> call(String bookingId) =>
      repository.trackRepairStatus(bookingId);
}

class UploadPaymentScreenshotUseCase implements UseCase<String, String> {
  final RepairRepository repository;
  const UploadPaymentScreenshotUseCase(this.repository);
  @override
  Future<String> call(String filePath) =>
      repository.uploadPaymentScreenshot(filePath);
}
