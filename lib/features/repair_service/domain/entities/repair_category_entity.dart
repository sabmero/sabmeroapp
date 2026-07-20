enum RepairStatus { pending, processing, onTheWay, completed, cancelled }

class RepairCategoryEntity {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final double baseCharge;

  const RepairCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.baseCharge,
  });
}

class RepairBookingEntity {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String address;
  final DateTime scheduledDate;
  final String timeSlot;
  final String? problemDescription;
  final List<String> damagePhotoUrls;
  final double? latitude;
  final double? longitude;
  final RepairStatus status;
  final String? technicianName;
  final double? charge;
  final String paymentMethod;
  final DateTime createdAt;

  const RepairBookingEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.address,
    required this.scheduledDate,
    required this.timeSlot,
    this.problemDescription,
    required this.damagePhotoUrls,
    this.latitude,
    this.longitude,
    required this.status,
    this.technicianName,
    this.charge,
    this.paymentMethod = 'Cash',
    required this.createdAt,
  });

  /// A booking can only be cancelled by the customer while it is still
  /// pending. Once a technician starts working (Processing or later) it can no
  /// longer be cancelled from the app.
  bool get isCancellable => status == RepairStatus.pending;

  String get statusLabel => switch (status) {
    RepairStatus.pending => 'Pending',
    RepairStatus.processing => 'Processing',
    RepairStatus.onTheWay => 'On the Way',
    RepairStatus.completed => 'Completed',
    RepairStatus.cancelled => 'Cancelled',
  };
}
