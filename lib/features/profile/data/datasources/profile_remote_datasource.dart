import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/address_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  });
  Future<String> getKycStatus();
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> addAddress(AddressModel address);
  Future<void> deleteAddress(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient, this._storage);

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  // The backend exposes no address book, so saved addresses are kept on-device.
  static const String _addressKey = 'saved_addresses';

  Future<UserModel> _fetchMe() async {
    final response = await _apiClient.dio.get(ApiConstants.me);
    final data = _apiClient.unwrapObject(response.data);
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      return await _fetchMe();
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (name != null && name.isNotEmpty) 'fullName': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (imagePath != null)
          'profilePicture': await MultipartFile.fromFile(imagePath),
      });
      final response = await _apiClient.dio.put(
        ApiConstants.updateProfile,
        data: formData,
      );
      final data = _apiClient.unwrapObject(response.data);
      AppLogger.info('Profile updated on server', tag: 'ProfileDataSource');
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<String> getKycStatus() async {
    try {
      final user = await _fetchMe();
      return user.isKycVerified ? 'verified' : 'pending';
    } on DioException catch (e) {
      _apiClient.handleError(e);
    }
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final raw = await _storage.read(key: _addressKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      AppLogger.error(
        'Failed to read addresses',
        tag: 'ProfileDataSource',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    final current = await getAddresses();
    final updated = [...current, address];
    await _persist(updated);
    return address;
  }

  @override
  Future<void> deleteAddress(String id) async {
    final current = await getAddresses();
    final updated = current.where((a) => a.id != id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<AddressModel> addresses) async {
    final encoded = jsonEncode(addresses.map((a) => a.toJson()).toList());
    await _storage.write(key: _addressKey, value: encoded);
  }
}

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSourceImpl(
    ref.watch(apiClientProvider),
    const FlutterSecureStorage(),
  ),
);
