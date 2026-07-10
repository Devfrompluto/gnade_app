import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gnade_app/src/imports/imports.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl implements SalesRepository {
  final supabase.SupabaseClient _supabaseClient;

  SalesRepositoryImpl(this._supabaseClient);

  @override
  FutureEither<List<Sale>> getSales({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  }) async {
    return runTask(() async {
      var query = _supabaseClient
          .from('sales')
          .select('*, sale_items(*)')
          .eq('business_id', businessId)
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      if (status != null && status.toLowerCase() != 'all') {
        query = query.eq('status', status.toLowerCase());
      }

      final response = List<Map<String, dynamic>>.from(
        await query.order('created_at', ascending: false),
      );

      final list = response
          .map((data) => SaleModel.fromMap(data) as Sale)
          .toList();

      return list;
    }, requiresNetwork: true);
  }

  @override
  FutureEither<SalesSummary> getSalesSummary({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return runTask(() async {
      final response = List<Map<String, dynamic>>.from(
        await _supabaseClient
            .from('sales')
            .select('total_amount, sale_items(quantity, total, products(cost_price))')
            .eq('business_id', businessId)
            .gte('created_at', startDate.toIso8601String())
            .lte('created_at', endDate.toIso8601String()),
      );

      double totalAmount = 0;
      double totalProfit = 0;
      int count = 0;

      for (final sale in response) {
        count++;
        totalAmount += double.tryParse(sale['total_amount']?.toString() ?? '') ?? 0.0;
        final items = sale['sale_items'] as List?;
        if (items != null) {
          for (final item in items) {
            final itemTotal = double.tryParse(item['total']?.toString() ?? '') ?? 0.0;
            final qty = double.tryParse(item['quantity']?.toString() ?? '') ?? 0.0;
            final products = item['products'] as Map<String, dynamic>?;
            final costPrice = double.tryParse(products?['cost_price']?.toString() ?? '') ?? 0.0;
            totalProfit += itemTotal - (costPrice * qty);
          }
        }
      }

      return SalesSummary(
        count: count,
        totalAmount: totalAmount,
        grossProfit: totalProfit,
      );
    }, requiresNetwork: true);
  }

  @override
  FutureEither<Sale> createSale({
    required String businessId,
    required String customerName,
    required double totalAmount,
    required double amountPaid,
    required double discount,
    required String paymentMethod,
    required String status,
    required String invoiceNo,
    required List<Map<String, dynamic>> items,
  }) async {
    return runTask(() async {
      // 1. Insert sale record
      final saleResponse = await _supabaseClient.from('sales').insert({
        'business_id': businessId,
        'customer_name': customerName,
        'total_amount': totalAmount,
        'amount_paid': amountPaid,
        'discount': discount,
        'payment_method': paymentMethod,
        'status': status,
        'invoice_no': invoiceNo,
      }).select().single();

      final String saleId = saleResponse['id'];

      // 2. Insert line items
      final List<Map<String, dynamic>> itemsToInsert = items.map((item) {
        return {
          'sale_id': saleId,
          'product_id': item['productId'],
          'product_name': item['productName'],
          'quantity': (item['quantity'] as double).toInt(),
          'unit_price': item['unitPrice'],
          'total': item['total'],
        };
      }).toList();

      await _supabaseClient.from('sale_items').insert(itemsToInsert);

      // 3. Decrement stock atomically for each product using RPC
      for (final item in items) {
        final productId = item['productId'];
        final quantity = item['quantity'] as double;
        if (productId != null) {
          await _supabaseClient.rpc<void>('decrement_stock', params: {
            'product_id': productId,
            'qty': quantity.toInt(),
          });
        }
      }

      // Return the saved sale with items
      final finalResponse = await _supabaseClient
          .from('sales')
          .select('*, sale_items(*)')
          .eq('id', saleId)
          .single();

      return SaleModel.fromMap(finalResponse);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<Sale> getSaleDetails(String saleId) async {
    return runTask(() async {
      final response = await _supabaseClient
          .from('sales')
          .select('*, sale_items(*)')
          .eq('id', saleId)
          .single();

      return SaleModel.fromMap(response);
    }, requiresNetwork: true);
  }
}
