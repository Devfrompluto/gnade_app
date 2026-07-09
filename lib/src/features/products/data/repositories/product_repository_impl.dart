import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gnade_app/src/imports/imports.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final supabase.SupabaseClient _supabaseClient;

  ProductRepositoryImpl(this._supabaseClient);

  @override
  FutureEither<List<Product>> getProducts(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('products')
          .select()
          .eq('business_id', businessId)
          .order('name', ascending: true);

      final list = (response as List)
          .map((data) => ProductModel.fromMap(data as Map<String, dynamic>) as Product)
          .toList();

      return right<Failure, List<Product>>(list);
    } catch (e) {
      return left<Failure, List<Product>>(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final response = await _supabaseClient.from('products').insert({
        'business_id': businessId,
        'name': name,
        'sku': sku.isEmpty ? null : sku,
        'category': category.isEmpty ? null : category,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'quantity': quantity.toInt(),
        'low_stock_at': lowStockAt.toInt(),
        'unit': unit,
        'expiry_date': expiryDate?.toIso8601String(),
      }).select().single();

      return right<Failure, Product>(ProductModel.fromMap(response));
    } catch (e) {
      return left<Failure, Product>(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<List<String>> getCategories(String businessId) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .select('name')
          .eq('business_id', businessId)
          .order('name', ascending: true);

      final list = (response as List)
          .map((data) => data['name'] as String)
          .toList();

      return right<Failure, List<String>>(list);
    } catch (e) {
      return left<Failure, List<String>>(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<String> createCategory(String businessId, String name) async {
    try {
      final response = await _supabaseClient
          .from('categories')
          .insert({
            'business_id': businessId,
            'name': name,
          })
          .select('name')
          .single();

      return right<Failure, String>(response['name'] as String);
    } catch (e) {
      return left<Failure, String>(ServerFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final response = await _supabaseClient.from('products').update({
        'name': name,
        'sku': sku.isEmpty ? null : sku,
        'category': category.isEmpty ? null : category,
        'cost_price': costPrice,
        'sell_price': sellPrice,
        'quantity': quantity.toInt(),
        'low_stock_at': lowStockAt.toInt(),
        'unit': unit,
        'expiry_date': expiryDate?.toIso8601String(),
      }).eq('id', productId).select().single();

      return right<Failure, Product>(ProductModel.fromMap(response));
    } catch (e) {
      return left<Failure, Product>(ServerFailure(e.toString()));
    }
  }
}
