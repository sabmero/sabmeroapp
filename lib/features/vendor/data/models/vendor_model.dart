import '../../domain/entities/vendor_entity.dart';

class VendorModel extends VendorEntity {
  const VendorModel({
    required super.id,
    required super.businessName,
    required super.ownerName,
    required super.phone,
    required super.address,
    required super.status,
    required super.commissionRate,
    required super.createdAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    final approved = json['isApproved'] as bool? ?? false;
    return VendorModel(
      id: '${json['id'] ?? ''}',
      businessName: json['businessName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['businessAddress'] as String? ?? '',
      status: approved ? 'approved' : 'pending',
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  int get productCountFromJson => 0;
}
