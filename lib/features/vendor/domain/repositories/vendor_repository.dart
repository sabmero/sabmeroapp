import '../entities/vendor_entity.dart';
import '../entities/vendor_sales_summary_entity.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../../../orders/domain/entities/order_entity.dart';

abstract class VendorRepository {
  Future<VendorEntity> registerVendor({required String businessName, required String address, required String phone});
  Future<VendorEntity> getVendorProfile();
  Future<List<ProductEntity>> getVendorProducts();
  Future<ProductEntity> createProduct(ProductEntity product);
  Future<ProductEntity> updateProduct(ProductEntity product);
  Future<void> deleteProduct(String productId);
  Future<List<OrderEntity>> getVendorOrders();
  Future<VendorSalesSummaryEntity> getVendorSales();
}
