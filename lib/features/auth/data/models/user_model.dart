import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.address,
    super.profileImageUrl,
    required super.isKycVerified,
    super.isActive,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['fullName'] as String? ?? json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String? ?? '',
      profileImageUrl:
          json['profilePictureUrl'] as String? ??
          json['profileImageUrl'] as String?,
      isKycVerified: json['isKycVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      role: userRoleFromString(json['role'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'phone': phone,
      'email': email,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'isKycVerified': isKycVerified,
      'isActive': isActive,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      profileImageUrl: entity.profileImageUrl,
      isKycVerified: entity.isKycVerified,
      isActive: entity.isActive,
      role: entity.role,
      createdAt: entity.createdAt,
    );
  }
}
