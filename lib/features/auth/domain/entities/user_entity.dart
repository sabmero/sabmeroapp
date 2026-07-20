enum UserRole { customer, vendor, technician, deliveryRider, admin }

UserRole userRoleFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'vendor':
    case 'seller':
      return UserRole.vendor;
    case 'technician':
      return UserRole.technician;
    case 'delivery':
    case 'deliveryrider':
    case 'rider':
      return UserRole.deliveryRider;
    case 'admin':
      return UserRole.admin;
    case 'user':
    case 'customer':
    default:
      return UserRole.customer;
  }
}

class UserEntity {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String address;
  final String? profileImageUrl;
  final bool isKycVerified;
  final bool isActive;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address = '',
    this.profileImageUrl,
    required this.isKycVerified,
    this.isActive = true,
    required this.role,
    required this.createdAt,
  });

  bool get isVendor => role == UserRole.vendor;
  bool get isTechnician => role == UserRole.technician;
  bool get isAdmin => role == UserRole.admin;

  UserEntity copyWith({
    String? name,
    String? email,
    String? address,
    String? profileImageUrl,
    bool? isKycVerified,
    bool? isActive,
  }) {
    return UserEntity(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      isActive: isActive ?? this.isActive,
      role: role,
      createdAt: createdAt,
    );
  }
}
