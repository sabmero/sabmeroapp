class VendorEntity {
  final String id;
  final String businessName;
  final String ownerName;
  final String phone;
  final String address;
  final String status;
  final double commissionRate;
  final DateTime createdAt;

  const VendorEntity({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.status,
    required this.commissionRate,
    required this.createdAt,
  });

  bool get isApproved => status == 'approved';
}
