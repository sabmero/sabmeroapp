import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/address_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  const ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> getProfile() async {
    try {
      return await remoteDataSource.getProfile();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<UserEntity> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    try {
      return await remoteDataSource.updateProfile(
        name: name,
        email: email,
        imagePath: imagePath,
      );
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<String> getKycStatus() async {
    try {
      return await remoteDataSource.getKycStatus();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<AddressEntity>> getAddresses() async {
    // Addresses are stored on-device; the datasource never throws DioException
    // here, but we still surface a clean failure if something goes wrong.
    try {
      return await remoteDataSource.getAddresses();
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    try {
      return await remoteDataSource.addAddress(
        AddressModel(
          id: address.id,
          label: address.label,
          fullAddress: address.fullAddress,
          city: address.city,
          isDefault: address.isDefault,
        ),
      );
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await remoteDataSource.deleteAddress(id);
    } on CacheException catch (e) {
      throw CacheFailure(message: e.message);
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});
