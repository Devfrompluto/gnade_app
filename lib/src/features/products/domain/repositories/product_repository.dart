import 'package:gnade_app/src/imports/imports.dart';

abstract class ProductRepository {
  FutureEither<List<Product>> getProducts(String businessId);

  FutureEither<Product> createProduct({
    required String businessId,
    required String name,
    required String sku,
    required String category,
    required double costPrice,
    required double sellPrice,
    required double quantity,
    required double lowStockAt,
    required String unit,
    DateTime? expiryDate,
  });

  FutureEither<List<String>> getCategories(String businessId);

  FutureEither<String> createCategory(String businessId, String name);

  FutureEither<Product> updateProduct({
    required String productId,
    required String name,
    required String sku,
    required String category,
    required double costPrice,
    required double sellPrice,
    required double quantity,
    required double lowStockAt,
    required String unit,
    DateTime? expiryDate,
  });
}
