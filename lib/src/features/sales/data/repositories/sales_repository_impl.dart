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
          .select('*, sale_items(*), sale_payments(*)')
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
    String? cashierName,
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
        if (cashierName != null) 'cashier_name': cashierName,
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

      // 3. Insert initial payment audit record in sale_payments
      if (amountPaid > 0) {
        await _supabaseClient.from('sale_payments').insert({
          'sale_id': saleId,
          'business_id': businessId,
          'amount': amountPaid,
          'payment_method': paymentMethod.toLowerCase(),
          'type': 'payment',
          'note': 'Initial Payment',
        });
      }

      // 4. Decrement stock atomically for each product using RPC
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

      // Return the saved sale with items and payment history
      final finalResponse = await _supabaseClient
          .from('sales')
          .select('*, sale_items(*), sale_payments(*)')
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
          .select('*, sale_items(*), sale_payments(*)')
          .eq('id', saleId)
          .single();

      return SaleModel.fromMap(response);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<Sale> recordPayment({
    required String saleId,
    required double paymentAmount,
    required String paymentMethod,
    String? reference,
    DateTime? paymentDate,
  }) async {
    return runTask(() async {
      final currentResponse = await _supabaseClient
          .from('sales')
          .select('amount_paid, total_amount, status, business_id')
          .eq('id', saleId)
          .single();

      final currentAmountPaid = double.tryParse(currentResponse['amount_paid']?.toString() ?? '0') ?? 0.0;
      final totalAmount = double.tryParse(currentResponse['total_amount']?.toString() ?? '0') ?? 0.0;
      final businessId = currentResponse['business_id']?.toString();

      final newAmountPaid = currentAmountPaid + paymentAmount;
      final String newStatus = newAmountPaid >= totalAmount
          ? 'paid'
          : (newAmountPaid > 0 ? 'partial' : 'debt');

      await _supabaseClient.from('sales').update({
        'amount_paid': newAmountPaid,
        'status': newStatus,
        'payment_method': paymentMethod.toLowerCase(),
      }).eq('id', saleId);

      // Audit log in sale_payments
      await _supabaseClient.from('sale_payments').insert({
        'sale_id': saleId,
        if (businessId != null) 'business_id': businessId,
        'amount': paymentAmount,
        'payment_method': paymentMethod.toLowerCase(),
        'type': 'payment',
        'note': reference != null && reference.isNotEmpty ? 'Payment ($reference)' : 'Payment Received',
      });

      final updatedResponse = await _supabaseClient
          .from('sales')
          .select('*, sale_items(*), sale_payments(*)')
          .eq('id', saleId)
          .single();

      return SaleModel.fromMap(updatedResponse);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<Sale> refundSale({
    required String saleId,
    required List<Map<String, dynamic>> refundedItems,
    required bool isFullRefund,
    required String reason,
  }) async {
    return runTask(() async {
      // 1. Restock products into inventory using RPC
      for (final item in refundedItems) {
        final productId = item['productId'];
        final qty = (item['quantity'] as num).toInt();
        if (productId != null && qty > 0) {
          await _supabaseClient.rpc<void>('increment_stock', params: {
            'product_id': productId,
            'qty': qty,
          });
        }
      }

      // 2. Fetch current sale_items from DB and update line item quantities & totals
      final existingSaleItems = List<Map<String, dynamic>>.from(
        await _supabaseClient
            .from('sale_items')
            .select('*')
            .eq('sale_id', saleId),
      );

      for (final saleItem in existingSaleItems) {
        final productId = saleItem['product_id'];
        final productName = saleItem['product_name'];
        final currentQty = double.tryParse(saleItem['quantity']?.toString() ?? '0') ?? 0.0;
        final unitPrice = double.tryParse(saleItem['unit_price']?.toString() ?? '0') ?? 0.0;

        // Find match in refundedItems
        final refItem = refundedItems.firstWhere(
          (r) => (r['productId'] != null && r['productId'] == productId) || (r['productName'] == productName),
          orElse: () => <String, dynamic>{},
        );

        if (refItem.isNotEmpty) {
          final refundedQty = (refItem['quantity'] as num).toDouble();
          final newQty = (currentQty - refundedQty).clamp(0.0, double.infinity);
          final newTotal = newQty * unitPrice;

          await _supabaseClient.from('sale_items').update({
            'quantity': newQty.toInt(),
            'total': newTotal,
          }).eq('id', saleItem['id']);
        }
      }

      // 3. Fetch current sale details
      final currentResponse = await _supabaseClient
          .from('sales')
          .select('total_amount, amount_paid, status, business_id')
          .eq('id', saleId)
          .single();

      final currentTotalAmount = double.tryParse(currentResponse['total_amount']?.toString() ?? '0') ?? 0.0;
      final currentAmountPaid = double.tryParse(currentResponse['amount_paid']?.toString() ?? '0') ?? 0.0;
      final businessId = currentResponse['business_id']?.toString();

      double refundTotal = 0;
      for (final item in refundedItems) {
        final qty = (item['quantity'] as num).toDouble();
        final unitPrice = (item['unitPrice'] as num).toDouble();
        refundTotal += qty * unitPrice;
      }

      final newTotalAmount = (currentTotalAmount - refundTotal).clamp(0.0, double.infinity);

      String newStatus;
      double newAmountPaid;

      if (isFullRefund || newTotalAmount <= 0) {
        newStatus = 'refunded';
        newAmountPaid = 0;
      } else {
        newAmountPaid = currentAmountPaid > newTotalAmount ? newTotalAmount : currentAmountPaid;
        newStatus = 'partial_refund';
      }

      // 4. Update sale header in Supabase
      await _supabaseClient.from('sales').update({
        'total_amount': newTotalAmount,
        'amount_paid': newAmountPaid,
        'status': newStatus,
      }).eq('id', saleId);

      // 5. Audit log refund entry in sale_payments
      if (refundTotal > 0) {
        await _supabaseClient.from('sale_payments').insert({
          'sale_id': saleId,
          if (businessId != null) 'business_id': businessId,
          'amount': -refundTotal,
          'payment_method': 'refund',
          'type': 'refund',
          'note': reason,
        });
      }

      final updatedResponse = await _supabaseClient
          .from('sales')
          .select('*, sale_items(*), sale_payments(*)')
          .eq('id', saleId)
          .single();

      return SaleModel.fromMap(updatedResponse);
    }, requiresNetwork: true);
  }
}
