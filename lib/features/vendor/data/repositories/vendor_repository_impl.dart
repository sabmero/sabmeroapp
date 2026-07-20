import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../shop/data/models/category_model.dart';
import '../../../shop/domain/entities/category_entity.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/entities/vendor_sales_summary_entity.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';

class VendorRepositoryImpl implements VendorRepository {
  final VendorRemoteDataSource remoteDataSource;
  const VendorRepositoryImpl(this.remoteDataSource);

  @override
  Future<VendorEntity> registerVendor({
    required String businessName,
    required String address,
    required String phone,
  }) async {
    try {
      return await remoteDataSource.registerVendor(
        businessName: businessName,
        address: address,
        phone: phone,
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<VendorEntity> getVendorProfile() async {
    try {
      return await remoteDataSource.getVendorProfile();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<ProductEntity>> getVendorProducts() async {
    try {
      return List<ProductEntity>.from(
        await remoteDataSource.getVendorProducts(),
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    try {
      return await remoteDataSource.createProduct(
        ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          vendorId: product.vendorId,
          vendorName: product.vendorName,
          imageUrls: product.imageUrls,
          variants: product.variants,
          basePrice: product.basePrice,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isAvailable: product.isAvailable,
          createdAt: product.createdAt,
        ),
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    try {
      return await remoteDataSource.updateProduct(
        ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          vendorId: product.vendorId,
          vendorName: product.vendorName,
          imageUrls: product.imageUrls,
          variants: product.variants,
          basePrice: product.basePrice,
          rating: product.rating,
          reviewCount: product.reviewCount,
          isAvailable: product.isAvailable,
          createdAt: product.createdAt,
        ),
      );
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await remoteDataSource.deleteProduct(productId);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<List<OrderEntity>> getVendorOrders() async {
    try {
      return List<OrderEntity>.from(await remoteDataSource.getVendorOrders());
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }

  @override
  Future<VendorSalesSummaryEntity> getVendorSales() async {
    try {
      return await remoteDataSource.getVendorSales();
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message);
    }
  }
}

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepositoryImpl(ref.watch(vendorRemoteDataSourceProvider));
});
