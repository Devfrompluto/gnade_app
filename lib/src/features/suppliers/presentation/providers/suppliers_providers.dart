import 'package:gnade_app/src/imports/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../domain/entities/supplier.dart';
import '../../data/models/supplier_model.dart';

final supplierSearchQueryProvider = StateProvider<String>((ref) => '');



class SuppliersListNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final Ref _ref;

  SuppliersListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final session = _ref.read(sessionProvider);
    final businessId = session.user?.businessId;

    if (businessId == null || businessId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((data) => SupplierModel.fromMap(data) as Supplier)
          .toList();

      state = AsyncValue.data(list);
    } catch (e) {
      AppLogger.error('Failed to fetch suppliers: $e');
      state = const AsyncValue.data([]);
    }
  }

  Future<Supplier?> addSupplier({
    required String name,
    required String phone,
    String? category,
    String? contactPerson,
    String? email,
    String? creditTerms,
    String? notes,
  }) async {
    final session = _ref.read(sessionProvider);
    final businessId = session.user?.businessId;

    if (businessId == null || businessId.isEmpty) {
      // Local fallback insert
      final newSupplier = Supplier(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phone: phone,
        category: category,
        contactPerson: contactPerson,
        email: email,
        creditTerms: creditTerms,
        notes: notes,
        createdAt: DateTime.now(),
      );
      final currentList = state.value ?? [];
      state = AsyncValue.data([newSupplier, ...currentList]);
      return newSupplier;
    }

    try {
      final response = await Supabase.instance.client.from('suppliers').insert({
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'supply_value': 0,
        'debt_amount': 0,
        if (category != null && category.isNotEmpty) 'category': category,
        if (contactPerson != null && contactPerson.isNotEmpty) 'contact_person': contactPerson,
        if (email != null && email.isNotEmpty) 'email': email,
        if (creditTerms != null && creditTerms.isNotEmpty) 'credit_terms': creditTerms,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }).select().single();

      final newSupplier = SupplierModel.fromMap(response);

      final currentList = state.value ?? [];
      state = AsyncValue.data([newSupplier, ...currentList]);

      return newSupplier;
    } catch (e) {
      AppLogger.error('Error adding supplier to Supabase: $e');
      // Create local instance so user is not blocked
      final newSupplier = Supplier(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phone: phone,
        category: category,
        contactPerson: contactPerson,
        email: email,
        creditTerms: creditTerms,
        notes: notes,
        createdAt: DateTime.now(),
      );
      final currentList = state.value ?? [];
      state = AsyncValue.data([newSupplier, ...currentList]);
      return newSupplier;
    }
  }
}

final suppliersProvider =
    StateNotifierProvider<SuppliersListNotifier, AsyncValue<List<Supplier>>>((ref) {
  return SuppliersListNotifier(ref);
});
