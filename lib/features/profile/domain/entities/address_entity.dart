class AddressEntity {
  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final bool isDefault;

  const AddressEntity({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.isDefault,
  });
}
