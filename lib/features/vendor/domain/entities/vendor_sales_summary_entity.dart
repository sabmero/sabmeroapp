class VendorSalesSummaryEntity {
  final double totalRevenue;
  final double totalCommission;
  final double netEarnings;
  final int totalOrders;
  final int pendingOrders;
  final int totalProducts;

  const VendorSalesSummaryEntity({
    required this.totalRevenue,
    required this.totalCommission,
    required this.netEarnings,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalProducts,
  });
}
