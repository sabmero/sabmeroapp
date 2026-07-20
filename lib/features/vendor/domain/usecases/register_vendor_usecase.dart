import '../../../../core/usecases/usecase.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../entities/vendor_entity.dart';
import '../entities/vendor_sales_summary_entity.dart';
import '../repositories/vendor_repository.dart';

class RegisterVendorParams {
  final String businessName;
  final String address;
  final String phone;

  const RegisterVendorParams({
    required this.businessName,
    required this.address,
    required this.phone,
  });
}

class RegisterVendorUseCase
    implements UseCase<VendorEntity, RegisterVendorParams> {
  final VendorRepository repository;
  const RegisterVendorUseCase(this.repository);

  @override
  Future<VendorEntity> call(RegisterVendorParams params) =>
      repository.registerVendor(
        businessName: params.businessName,
        address: params.address,
        phone: params.phone,
      );
}

class GetVendorProfileUseCase implements UseCase<VendorEntity, NoParams> {
  final VendorRepository repository;
  const GetVendorProfileUseCase(this.repository);

  @override
  Future<VendorEntity> call(NoParams params) => repository.getVendorProfile();
}

class GetVendorProductsUseCase
    implements UseCase<List<ProductEntity>, NoParams> {
  final VendorRepository repository;
  const GetVendorProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(NoParams params) =>
      repository.getVendorProducts();
}

class CreateProductUseCase implements UseCase<ProductEntity, ProductEntity> {
  final VendorRepository repository;
  const CreateProductUseCase(this.repository);

  @override
  Future<ProductEntity> call(ProductEntity params) =>
      repository.createProduct(params);
}

class UpdateProductUseCase implements UseCase<ProductEntity, ProductEntity> {
  final VendorRepository repository;
  const UpdateProductUseCase(this.repository);

  @override
  Future<ProductEntity> call(ProductEntity params) =>
      repository.updateProduct(params);
}

class DeleteProductUseCase implements UseCase<void, String> {
  final VendorRepository repository;
  const DeleteProductUseCase(this.repository);

  @override
  Future<void> call(String productId) => repository.deleteProduct(productId);
}

class GetVendorOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final VendorRepository repository;
  const GetVendorOrdersUseCase(this.repository);

  @override
  Future<List<OrderEntity>> call(NoParams params) =>
      repository.getVendorOrders();
}

class GetVendorSalesUseCase
    implements UseCase<VendorSalesSummaryEntity, NoParams> {
  final VendorRepository repository;
  const GetVendorSalesUseCase(this.repository);

  @override
  Future<VendorSalesSummaryEntity> call(NoParams params) =>
      repository.getVendorSales();
}
