import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/entities/vendor_sales_summary_entity.dart';

class VendorSalesSummaryModel extends VendorSalesSummaryEntity {
  const VendorSalesSummaryModel({
    required super.totalRevenue,
    required super.totalCommission,
    required super.netEarnings,
    required super.totalOrders,
    required super.pendingOrders,
    required super.totalProducts,
  });

  // There is no sales API; the summary is derived from the vendor's orders
  // and product count, using the vendor's commission rate.
  factory VendorSalesSummaryModel.fromOrders({
    required List<OrderEntity> orders,
    required int totalProducts,
    required double commissionRate,
  }) {
    final delivered = orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();
    final revenue = delivered.fold<double>(0, (sum, o) => sum + o.total);
    final commission = revenue * commissionRate;
    final pending = orders
        .where(
          (o) =>
              o.status == OrderStatus.pending ||
              o.status == OrderStatus.confirmed ||
              o.status == OrderStatus.processing,
        )
        .length;
    return VendorSalesSummaryModel(
      totalRevenue: revenue,
      totalCommission: commission,
      netEarnings: revenue - commission,
      totalOrders: orders.length,
      pendingOrders: pending,
      totalProducts: totalProducts,
    );
  }
}
