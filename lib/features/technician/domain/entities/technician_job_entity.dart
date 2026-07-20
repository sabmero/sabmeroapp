enum TechnicianJobStatus { approved, processing, onTheWay, completed }

TechnicianJobStatus technicianJobStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'processing':
      return TechnicianJobStatus.processing;
    case 'ontheway':
    case 'on_the_way':
      return TechnicianJobStatus.onTheWay;
    case 'completed':
      return TechnicianJobStatus.completed;
    case 'approved':
    default:
      return TechnicianJobStatus.approved;
  }
}

String technicianJobStatusToApiString(TechnicianJobStatus status) =>
    switch (status) {
      TechnicianJobStatus.approved => 'Approved',
      TechnicianJobStatus.processing => 'Processing',
      TechnicianJobStatus.onTheWay => 'OnTheWay',
      TechnicianJobStatus.completed => 'Completed',
    };

/// A repair/service booking that has been assigned to the logged-in
/// technician. Carries the customer's contact details and address so the
/// technician knows exactly where — and to whom — they're going.
class TechnicianJobEntity {
  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceType;
  final DateTime bookingDate;
  final String timeSlot;
  final double latitude;
  final double longitude;
  final String serviceAddress;
  final String? damageImagePath;
  final TechnicianJobStatus status;
  final String paymentMethod;
  final String paymentStatus;
  final double? serviceCharge;
  final DateTime createdAt;

  const TechnicianJobEntity({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    required this.bookingDate,
    required this.timeSlot,
    required this.latitude,
    required this.longitude,
    required this.serviceAddress,
    this.damageImagePath,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.serviceCharge,
    required this.createdAt,
  });

  String get statusLabel => switch (status) {
    TechnicianJobStatus.approved => 'New Job',
    TechnicianJobStatus.processing => 'In Progress',
    TechnicianJobStatus.onTheWay => 'On the Way',
    TechnicianJobStatus.completed => 'Completed',
  };

  bool get isActive => status != TechnicianJobStatus.completed;

  /// The next status this job can be moved to by the technician, or null if
  /// it's already at its final state.
  TechnicianJobStatus? get nextStatus => switch (status) {
    TechnicianJobStatus.approved => TechnicianJobStatus.processing,
    TechnicianJobStatus.processing => TechnicianJobStatus.onTheWay,
    TechnicianJobStatus.onTheWay => TechnicianJobStatus.completed,
    TechnicianJobStatus.completed => null,
  };

  String get nextStatusActionLabel => switch (status) {
    TechnicianJobStatus.approved => 'Start Job',
    TechnicianJobStatus.processing => 'On My Way',
    TechnicianJobStatus.onTheWay => 'Mark Completed',
    TechnicianJobStatus.completed => '',
  };
}
