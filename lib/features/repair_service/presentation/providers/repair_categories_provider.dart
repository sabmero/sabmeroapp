import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/repositories/repair_repository_impl.dart';
import '../../domain/entities/repair_category_entity.dart';
import '../../domain/repositories/repair_repository.dart';

final repairCategoriesProvider =
    AsyncNotifierProvider<RepairCategoriesNotifier, List<RepairCategoryEntity>>(
      RepairCategoriesNotifier.new,
    );

class RepairCategoriesNotifier
    extends AsyncNotifier<List<RepairCategoryEntity>> {
  @override
  Future<List<RepairCategoryEntity>> build() async {
    return GetRepairCategoriesUseCase(ref.watch(repairRepositoryProvider))(
      const NoParams(),
    );
  }
}

class RepairBookingState {
  final bool isLoading;
  final RepairBookingEntity? booking;
  final String? error;

  const RepairBookingState({this.isLoading = false, this.booking, this.error});

  const RepairBookingState.idle()
    : this(isLoading: false, booking: null, error: null);
}

final repairBookingNotifierProvider =
    NotifierProvider<RepairBookingNotifier, RepairBookingState>(
      RepairBookingNotifier.new,
    );

class RepairBookingNotifier extends Notifier<RepairBookingState> {
  @override
  RepairBookingState build() => const RepairBookingState.idle();

  Future<RepairBookingEntity?> createBooking({
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
    String? paymentScreenshotLocalPath,
  }) async {
    state = const RepairBookingState(isLoading: true);
    try {
      final repository = ref.read(repairRepositoryProvider);

      // For QR payments, upload the proof screenshot first and send the
      // returned server path with the booking.
      String? screenshotServerPath;
      if (paymentMethod == 'QR' &&
          paymentScreenshotLocalPath != null &&
          paymentScreenshotLocalPath.isNotEmpty) {
        screenshotServerPath = await UploadPaymentScreenshotUseCase(repository)(
          paymentScreenshotLocalPath,
        );
      }

      final booking = await CreateRepairBookingUseCase(repository)(
        CreateRepairBookingParams(
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
          paymentScreenshotPath: screenshotServerPath,
        ),
      );
      state = RepairBookingState(booking: booking);
      AppLogger.info('Repair booking created', tag: 'RepairBookingNotifier');
      // Make the new booking visible in the "My Bookings" list immediately.
      ref.invalidate(repairBookingsListProvider);
      return booking;
    } catch (e, st) {
      AppLogger.error(
        'Repair booking failed',
        tag: 'RepairBookingNotifier',
        error: e,
        stackTrace: st,
      );
      state = RepairBookingState(error: _readableError(e));
      return null;
    }
  }

  String _readableError(Object e) => e
      .toString()
      .replaceFirst('ServerFailure: ', '')
      .replaceFirst('Exception: ', '');

  void reset() => state = const RepairBookingState.idle();
}

/// Drives the cancel action and exposes a loading flag per request so the UI
/// can disable the cancel button while the call is in flight.
class RepairCancelNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<({bool success, String message})> cancel(String bookingId) async {
    state = true;
    try {
      await CancelRepairBookingUseCase(ref.read(repairRepositoryProvider))(
        bookingId,
      );
      AppLogger.info('Booking cancelled', tag: 'RepairCancelNotifier');
      ref.invalidate(repairBookingsListProvider);
      return (success: true, message: 'Booking cancelled.');
    } catch (e, st) {
      AppLogger.error(
        'Cancel booking failed',
        tag: 'RepairCancelNotifier',
        error: e,
        stackTrace: st,
      );
      return (success: false, message: _readableError(e));
    } finally {
      state = false;
    }
  }

  String _readableError(Object e) {
    final raw = e.toString();
    return raw
        .replaceFirst('ServerFailure: ', '')
        .replaceFirst('Exception: ', '');
  }
}

final repairCancelNotifierProvider =
    NotifierProvider<RepairCancelNotifier, bool>(RepairCancelNotifier.new);

final repairBookingsListProvider = FutureProvider<List<RepairBookingEntity>>((
  ref,
) async {
  return GetRepairBookingsUseCase(ref.watch(repairRepositoryProvider))(
    const NoParams(),
  );
});
