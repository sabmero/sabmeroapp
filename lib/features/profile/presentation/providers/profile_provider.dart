import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, UserEntity?>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    try {
      return await GetProfileUseCase(ref.watch(profileRepositoryProvider))(
        const NoParams(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<UserEntity> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updated = await UpdateProfileUseCase(
        ref.read(profileRepositoryProvider),
      )(UpdateProfileParams(name: name, email: email, imagePath: imagePath));
      state = AsyncValue.data(updated);
      AppLogger.info('Profile updated', tag: 'ProfileNotifier');
      return updated;
    } catch (e, st) {
      AppLogger.error(
        'Profile update failed',
        tag: 'ProfileNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.error(e, st);
      // Rethrow so the Edit Profile screen can surface the message
      // (e.g. "That email is already used by another account.").
      rethrow;
    }
  }
}

final addressesProvider = FutureProvider<List<AddressEntity>>((ref) async {
  return ref.watch(profileRepositoryProvider).getAddresses();
});
