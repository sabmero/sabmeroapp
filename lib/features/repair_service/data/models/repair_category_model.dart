import '../../../shop/data/models/category_model.dart' show resolveImageUrl;
import '../../domain/entities/repair_category_entity.dart';

RepairStatus repairStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'processing':
    case 'assigned':
      return RepairStatus.processing;
    case 'ontheway':
    case 'on_the_way':
      return RepairStatus.onTheWay;
    case 'completed':
    case 'done':
      return RepairStatus.completed;
    case 'cancelled':
    case 'canceled':
      return RepairStatus.cancelled;
    case 'pending':
    default:
      return RepairStatus.pending;
  }
}

class RepairCategoryModel extends RepairCategoryEntity {
  const RepairCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconName,
    required super.baseCharge,
  });
}

class RepairBookingModel extends RepairBookingEntity {
  const RepairBookingModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.categoryName,
    required super.address,
    required super.scheduledDate,
    required super.timeSlot,
    super.problemDescription,
    required super.damagePhotoUrls,
    super.latitude,
    super.longitude,
    required super.status,
    super.technicianName,
    super.charge,
    super.paymentMethod,
    required super.createdAt,
  });

  factory RepairBookingModel.fromJson(Map<String, dynamic> json) {
    final damage = resolveImageUrl(json['damageImagePath'] as String?);
    final serviceType = json['serviceType'] as String? ?? '';
    return RepairBookingModel(
      id: '${json['id'] ?? ''}',
      userId: '${json['userId'] ?? ''}',
      // The backend has no repair-category table; serviceType doubles as both.
      categoryId: serviceType,
      categoryName: serviceType,
      address: json['serviceAddress'] as String? ?? '',
      scheduledDate:
          DateTime.tryParse(json['bookingDate'] as String? ?? '') ??
          DateTime.now(),
      timeSlot: json['timeSlot'] as String? ?? '',
      problemDescription: null,
      damagePhotoUrls: damage.isEmpty ? const [] : [damage],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: repairStatusFromString(json['status'] as String?),
      technicianName: json['technicianName'] as String?,
      charge: (json['serviceCharge'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
