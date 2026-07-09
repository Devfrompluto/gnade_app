import 'package:gnade_app/src/imports/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../data/repositories/customer_repository_impl.dart';

enum CustomerFilterType { all, debtors, depositers }

class CustomerListNotifier extends StateNotifier<List<Customer>> {
  final CustomerRepository _repository;
  final String? _businessId;

  CustomerListNotifier(this._repository, this._businessId) : super([]) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    if (_businessId == null) return;
    final result = await _repository.getCustomers(_businessId);
    result.fold(
      (failure) => AppLogger.error('Failed to load customers: ${failure.message}'),
      (customers) => state = customers,
    );
  }

  Future<Customer?> addCustomer({
    required String name,
    required String phone,
    String? email,
    String? address,
    String? notes,
  }) async {
    if (_businessId == null) return null;
    final result = await _repository.createCustomer(
      businessId: _businessId,
      name: name,
      phone: phone,
      email: email,
      address: address,
      notes: notes,
    );
    return result.fold(
      (failure) {
        AppLogger.error('Failed to add customer: ${failure.message}');
        return null;
      },
      (newCustomer) {
        state = [newCustomer, ...state];
        return newCustomer;
      },
    );
  }
}

// State Providers
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(Supabase.instance.client);
});

final customerListProvider = StateNotifierProvider<CustomerListNotifier, List<Customer>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  return CustomerListNotifier(repo, businessId);
});

final customerFilterProvider = StateProvider<CustomerFilterType>((ref) {
  return CustomerFilterType.all;
});

final customerSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Computed list provider
final filteredCustomersProvider = Provider<List<Customer>>((ref) {
  final customers = ref.watch(customerListProvider);
  final filter = ref.watch(customerFilterProvider);
  final query = ref.watch(customerSearchQueryProvider).toLowerCase().trim();

  List<Customer> list = customers;

  // 1. Search Query filter
  if (query.isNotEmpty) {
    list = list.where((c) => c.name.toLowerCase().contains(query) || c.phone.contains(query)).toList();
  }

  // 2. Pill filters
  if (filter == CustomerFilterType.debtors) {
    list = list.where((c) => c.balance < 0).toList();
  } else if (filter == CustomerFilterType.depositers) {
    list = list.where((c) => c.balance > 0).toList();
  }

  return list;
});
