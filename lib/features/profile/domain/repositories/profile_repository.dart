import '../../../auth/domain/entities/user_entity.dart';
import '../entities/address_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  });
  Future<String> getKycStatus();
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> addAddress(AddressEntity address);
  Future<void> deleteAddress(String id);
}
