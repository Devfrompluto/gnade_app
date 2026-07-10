import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:gnade_app/src/utils/utils.dart';
import 'package:gnade_app/src/features/home/domain/entities/dashboard_data.dart';
import 'package:gnade_app/src/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final SupabaseClient _client;

  HomeRepositoryImpl(this._client);

  @override
  FutureEither<DashboardData> getDashboardData(String businessId) async {
    return runTask(() async {
      // 1. Calculate today's date bounds
      final now = DateTime.now();
      // Start of today in local time, converted to UTC for DB queries
      final startOfToday = DateTime(now.year, now.month, now.day).toUtc().toIso8601String();
      // Today's date in local YYYY-MM-DD format for expenses table
      final todayLocalDate = DateFormat('yyyy-MM-dd').format(now);

      // 2. Fetch today's sales
      final salesData = List<Map<String, dynamic>>.from(
        await _client
            .from('sales')
            .select('total_amount')
            .eq('business_id', businessId)
            .gte('created_at', startOfToday),
      );

      double todaySales = 0;
      for (final row in salesData) {
        todaySales += (row['total_amount'] as num).toDouble();
      }

      // 3. Fetch today's expenses
      final expensesData = List<Map<String, dynamic>>.from(
        await _client
            .from('expenses')
            .select('amount')
            .eq('business_id', businessId)
            .eq('date', todayLocalDate),
      );

      double todayExpenses = 0;
      for (final row in expensesData) {
        todayExpenses += (row['amount'] as num).toDouble();
      }

      // 4. Fetch today's sold products and group them
      // inner join on sales permits filtering by business_id and date
      final saleItemsData = List<Map<String, dynamic>>.from(
        await _client
            .from('sale_items')
            .select('product_name, quantity, total, sales!inner(business_id, created_at)')
            .eq('sales.business_id', businessId)
            .gte('sales.created_at', startOfToday),
      );

      final Map<String, SoldProductItem> groupedProducts = {};
      for (final row in saleItemsData) {
        final name = row['product_name'] as String;
        final qty = (row['quantity'] as num).toDouble();
        final total = (row['total'] as num).toDouble();

        if (groupedProducts.containsKey(name)) {
          final existing = groupedProducts[name]!;
          groupedProducts[name] = SoldProductItem(
            productName: name,
            quantitySold: existing.quantitySold + qty,
            salesAmount: existing.salesAmount + total,
          );
        } else {
          groupedProducts[name] = SoldProductItem(
            productName: name,
            quantitySold: qty,
            salesAmount: total,
          );
        }
      }

      return DashboardData(
        todaySales: todaySales,
        todayExpenses: todayExpenses,
        soldProducts: groupedProducts.values.toList(),
      );
    }, requiresNetwork: true);
  }
}
