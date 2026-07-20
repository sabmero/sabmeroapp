import '../../domain/entities/technician_job_entity.dart';

class TechnicianJobModel extends TechnicianJobEntity {
  const TechnicianJobModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.serviceType,
    required super.bookingDate,
    required super.timeSlot,
    required super.latitude,
    required super.longitude,
    required super.serviceAddress,
    super.damageImagePath,
    required super.status,
    required super.paymentMethod,
    required super.paymentStatus,
    super.serviceCharge,
    required super.createdAt,
  });

  factory TechnicianJobModel.fromJson(Map<String, dynamic> json) {
    return TechnicianJobModel(
      id: '${json['id'] ?? ''}',
      customerName: json['customerName'] as String? ?? 'Customer',
      customerPhone: json['customerPhone'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? 'Service',
      bookingDate:
          DateTime.tryParse(json['bookingDate'] as String? ?? '') ??
          DateTime.now(),
      timeSlot: json['timeSlot'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      serviceAddress: json['serviceAddress'] as String? ?? '',
      damageImagePath: json['damageImagePath'] as String?,
      status: technicianJobStatusFromString(json['status'] as String?),
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
