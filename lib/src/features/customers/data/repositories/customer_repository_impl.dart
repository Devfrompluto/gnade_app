import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gnade_app/src/imports/imports.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final supabase.SupabaseClient _supabaseClient;

  CustomerRepositoryImpl(this._supabaseClient);

  @override
  FutureEither<List<Customer>> getCustomers(String businessId) async {
    return runTask(() async {
      // 1. Fetch all customer profiles
      final customersResponse = List<Map<String, dynamic>>.from(
        await _supabaseClient
            .from('customers')
            .select()
            .eq('business_id', businessId)
            .order('name', ascending: true),
      );

      // 2. Fetch all sales for this business to link dynamic history, totals owed, and deposits
      final salesList = List<Map<String, dynamic>>.from(
        await _supabaseClient
            .from('sales')
            .select('*, sale_items(quantity)')
            .eq('business_id', businessId)
            .order('created_at', ascending: false),
      );

      // Group sales by customer name
      final Map<String, List<CustomerOrder>> customerOrdersMap = {};
      final Map<String, double> customerOwedMap = {};
      final Map<String, double> customerDepositMap = {};

      for (final sale in salesList) {
        final custName = sale['customer_name']?.toString() ?? 'Retail Customer';
        final saleId = sale['id']?.toString() ?? '';
        final invoiceNo = sale['invoice_no']?.toString() ?? saleId;
        final status = (sale['status']?.toString() ?? 'paid').toUpperCase();
        final createdAtStr = sale['created_at']?.toString() ?? '';
        final date = DateTime.tryParse(createdAtStr) ?? DateTime.now();
        final totalAmount = double.tryParse(sale['total_amount']?.toString() ?? '') ?? 0.0;
        final amountPaid = double.tryParse(sale['amount_paid']?.toString() ?? '') ?? 0.0;

        // Calculate items count
        int itemsCount = 0;
        final items = sale['sale_items'] as List?;
        if (items != null) {
          for (final item in items) {
            final qty = double.tryParse(item['quantity']?.toString() ?? '') ?? 0.0;
            itemsCount += qty.toInt();
          }
        }

        final order = CustomerOrder(
          id: saleId,
          invoiceNo: invoiceNo,
          status: status,
          date: date,
          itemsCount: itemsCount,
          amount: totalAmount,
        );

        customerOrdersMap.putIfAbsent(custName.trim().toLowerCase(), () => []).add(order);

        // Calculate owed balance
        if (status == 'PARTIAL' || status == 'DEBT' || status == 'UNPAID') {
          final owed = totalAmount - amountPaid;
          if (owed > 0) {
            final key = custName.trim().toLowerCase();
            customerOwedMap[key] = (customerOwedMap[key] ?? 0.0) + owed;
          }
        }
        
        // If they paid more than total (deposit)
        if (amountPaid > totalAmount) {
          final deposit = amountPaid - totalAmount;
          final key = custName.trim().toLowerCase();
          customerDepositMap[key] = (customerDepositMap[key] ?? 0.0) + deposit;
        }
      }

      final list = customersResponse.map((data) {
        final name = data['name']?.toString() ?? '';
        final key = name.trim().toLowerCase();
        final orders = customerOrdersMap[key] ?? [];
        final computedOwed = customerOwedMap[key] ?? 0.0;
        final computedDeposit = customerDepositMap[key] ?? 0.0;

        // Merge computed values with DB values
        final dbOwed = double.tryParse(data['total_owed']?.toString() ?? '') ?? 0.0;
        final dbDeposit = double.tryParse(data['deposit_amount']?.toString() ?? '') ?? 0.0;

        return Customer(
          id: data['id']?.toString() ?? '',
          businessId: data['business_id']?.toString() ?? '',
          name: name,
          phone: data['phone']?.toString() ?? '',
          email: data['email']?.toString(),
          address: data['address']?.toString(),
          notes: data['notes']?.toString(),
          totalOwed: computedOwed > 0 ? computedOwed : dbOwed,
          depositAmount: computedDeposit > 0 ? computedDeposit : dbDeposit,
          orders: orders,
        );
      }).toList();

      return list;
    }, requiresNetwork: true);
  }

  @override
  FutureEither<Customer> createCustomer({
    required String businessId,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await _supabaseClient.from('customers').insert({
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'notes': notes,
      }).select().single();

      return right<Failure, Customer>(CustomerModel.fromMap(response));
    } catch (e) {
      return left<Failure, Customer>(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<Customer> updateCustomer({
    required String id,
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    try {
      final response = await _supabaseClient
          .from('customers')
          .update({
            'name': name,
            'phone': phone,
            'email': email,
            'address': address,
            'notes': notes,
          })
          .eq('id', id)
          .select()
          .single();

      return right<Failure, Customer>(CustomerModel.fromMap(response));
    } catch (e) {
      return left<Failure, Customer>(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteCustomer(String id) async {
    try {
      await _supabaseClient.from('customers').delete().eq('id', id);
      return right<Failure, void>(null);
    } catch (e) {
      return left<Failure, void>(ServerFailure(e.toString()));
    }
  }
}
