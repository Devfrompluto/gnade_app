import 'package:gnade_app/src/imports/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../widgets/inventory_item_tile.dart'; // To reuse StockStatus if needed, or we can declare it here

// We will declare StockStatus here to be used feature-wide
enum ProductFilterType { all, expired, lowStock }

enum ProductLayoutType { list, grid }

enum ProductSortType {
  newestToOldest,
  oldToNew,
  alphabeticalAZ,
  alphabeticalZA,
  quantityHighToLow,
  quantityLowToHigh,
}

class SupplierPurchaseItemMock {
  final String name;
  final double qty;
  final double unitPrice;
  final String total;

  const SupplierPurchaseItemMock({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.total,
  });
}

class SupplierPurchaseMock {
  final String id;
  final String itemsSummary;
  final String totalAmount;
  final String balanceDue;
  final String status; // 'Credit' or 'Paid'
  final String date;
  final List<SupplierPurchaseItemMock> items;
  final String subtotal;
  final String expenses;
  final String staff;

  const SupplierPurchaseMock({
    required this.id,
    required this.itemsSummary,
    required this.totalAmount,
    required this.balanceDue,
    required this.status,
    required this.date,
    this.items = const [],
    this.subtotal = '0',
    this.expenses = '0',
    this.staff = 'gnade',
  });
}

class SupplierMock {
  final String id;
  final String name;
  final String phone;
  final String supplyValue;
  final String debtAmount;
  final List<SupplierPurchaseMock> purchases;

  const SupplierMock({
    required this.id,
    required this.name,
    required this.phone,
    required this.supplyValue,
    required this.debtAmount,
    required this.purchases,
  });
}



// Initial mock suppliers list matching user mockup
final _initialSuppliers = [
  const SupplierMock(
    id: 's1',
    name: 'Senna Atlantic',
    phone: '+2348033332133',
    supplyValue: '6,381,100',
    debtAmount: '5,381,100',
    purchases: [
      SupplierPurchaseMock(
        id: '#BZ_PAPafQxP9XA',
        itemsSummary: '20.0x Star Bottle, 40.0x Legend Bottle,...',
        totalAmount: '4,433,100',
        balanceDue: '4,433,100',
        status: 'Credit',
        date: 'Jun 13, 2026 21:20',
        subtotal: '4,428,100',
        expenses: '5,000',
        staff: 'gnade',
        items: [
          SupplierPurchaseItemMock(
            name: 'Star Bottle',
            qty: 20,
            unitPrice: 11200,
            total: '224,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Legend Bottle',
            qty: 40,
            unitPrice: 11200,
            total: '448,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Gulder bottle',
            qty: 10,
            unitPrice: 11400,
            total: '114,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Desperado Bottle',
            qty: 10,
            unitPrice: 20600,
            total: '206,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Guinness Stout 60cl (Big)',
            qty: 20,
            unitPrice: 15280,
            total: '305,600',
          ),
        ],
      ),
      SupplierPurchaseMock(
        id: '#BZ_XYX992kkL21',
        itemsSummary: '10.0x Heineken Cans, 5.0x Red Label...',
        totalAmount: '1,953,000',
        balanceDue: '0',
        status: 'Paid',
        date: 'Jun 10, 2026 14:45',
        subtotal: '1,953,000',
        expenses: '0',
        staff: 'gnade',
        items: [
          SupplierPurchaseItemMock(
            name: 'Heineken Cans',
            qty: 10,
            unitPrice: 150000,
            total: '1,500,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Red Label',
            qty: 5,
            unitPrice: 90600,
            total: '453,000',
          ),
        ],
      ),
    ],
  ),
  const SupplierMock(
    id: 's2',
    name: 'Golden Breweries',
    phone: '+2348022223344',
    supplyValue: '1,200,000',
    debtAmount: '0',
    purchases: [
      SupplierPurchaseMock(
        id: '#BZ_GLD12345678',
        itemsSummary: '50.0x Tiger bottle, 10.0x Star Bottle...',
        totalAmount: '1,200,000',
        balanceDue: '0',
        status: 'Paid',
        date: 'May 28, 2026 10:15',
        subtotal: '1,200,000',
        expenses: '0',
        staff: 'gnade',
        items: [
          SupplierPurchaseItemMock(
            name: 'Tiger bottle',
            qty: 50,
            unitPrice: 20000,
            total: '1,000,000',
          ),
          SupplierPurchaseItemMock(
            name: 'Star Bottle',
            qty: 10,
            unitPrice: 20000,
            total: '200,000',
          ),
        ],
      ),
    ],
  ),
  const SupplierMock(
    id: 's3',
    name: 'Coca Cola Hellenic',
    phone: '+2348123456789',
    supplyValue: '3,500,000',
    debtAmount: '500,000',
    purchases: [],
  ),
  const SupplierMock(
    id: 's4',
    name: 'Chi Limited',
    phone: '+2348098765432',
    supplyValue: '4,200,000',
    debtAmount: '1,200,000',
    purchases: [],
  ),
  const SupplierMock(
    id: 's5',
    name: 'Seven-Up Bottling',
    phone: '+2348011112222',
    supplyValue: '2,800,000',
    debtAmount: '0',
    purchases: [],
  ),
  const SupplierMock(
    id: 's6',
    name: 'Promasidor',
    phone: '+2348044445555',
    supplyValue: '1,500,000',
    debtAmount: '250,000',
    purchases: [],
  ),
];

// Layout Provider (List or Grid)
final productsLayoutProvider = StateProvider<ProductLayoutType>((ref) {
  return ProductLayoutType.list;
});

// Sort Provider
final productsSortProvider = StateProvider<ProductSortType>((ref) {
  return ProductSortType.quantityLowToHigh; // Default selected in user image
});

// Filter Pill Provider
final productsFilterProvider = StateProvider<ProductFilterType>((ref) {
  return ProductFilterType.all;
});

// Products List Provider (to allow addition/modification if needed)
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(Supabase.instance.client);
});

final productsListProvider = StateNotifierProvider<ProductsListNotifier, List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  return ProductsListNotifier(repo, businessId);
});

class ProductsListNotifier extends StateNotifier<List<Product>> {
  final ProductRepository _repository;
  final String? _businessId;

  ProductsListNotifier(this._repository, this._businessId) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_businessId == null) return;
    final result = await _repository.getProducts(_businessId);
    result.fold(
      (failure) => AppLogger.error('Failed to load products: ${failure.message}'),
      (products) => state = products,
    );
  }

  Future<Product?> addProduct({
    required String name,
    required String sku,
    required String category,
    required double costPrice,
    required double sellPrice,
    required double quantity,
    required double lowStockAt,
    required String unit,
    DateTime? expiryDate,
    String? supplierId,
    String? supplierName,
  }) async {
    if (_businessId == null) return null;
    final result = await _repository.createProduct(
      businessId: _businessId,
      name: name,
      sku: sku,
      category: category,
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      lowStockAt: lowStockAt,
      unit: unit,
      expiryDate: expiryDate,
      supplierId: supplierId,
      supplierName: supplierName,
    );
    return result.fold(
      (failure) {
        AppLogger.error('Failed to create product: ${failure.message}');
        return null;
      },
      (newProduct) {
        state = [...state, newProduct];
        return newProduct;
      },
    );
  }

  Future<Product?> updateProduct({
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
    String? supplierId,
    String? supplierName,
  }) async {
    final result = await _repository.updateProduct(
      productId: productId,
      name: name,
      sku: sku,
      category: category,
      costPrice: costPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      lowStockAt: lowStockAt,
      unit: unit,
      expiryDate: expiryDate,
      supplierId: supplierId,
      supplierName: supplierName,
    );
    return result.fold(
      (failure) {
        AppLogger.error('Failed to update product: ${failure.message}');
        return null;
      },
      (updatedProduct) {
        state = [
          for (final p in state)
            if (p.id == productId) updatedProduct else p
        ];
        return updatedProduct;
      },
    );
  }
}

// Categories List Provider
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<String>>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  return CategoriesNotifier(repo, businessId);
});

class CategoriesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final ProductRepository _repository;
  final String? _businessId;

  CategoriesNotifier(this._repository, this._businessId) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    if (_businessId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await _repository.getCategories(_businessId);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (categories) => state = AsyncValue.data(categories),
    );
  }

  Future<String?> addCategory(String name) async {
    if (_businessId == null) return null;
    final result = await _repository.createCategory(_businessId, name);
    return result.fold(
      (failure) {
        AppLogger.error('Failed to create category: ${failure.message}');
        return null;
      },
      (newCategory) {
        state.whenData((list) {
          if (!list.contains(newCategory)) {
            state = AsyncValue.data([...list, newCategory]);
          }
        });
        return newCategory;
      },
    );
  }
}

// Category Filter Provider
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

// Filtered and Sorted Products Provider
final filteredSortedProductsProvider = Provider<List<ProductMock>>((ref) {
  final products = ref.watch(productsListProvider);
  final filter = ref.watch(productsFilterProvider);
  final sortType = ref.watch(productsSortProvider);
  final selectedCategory = ref.watch(selectedCategoryFilterProvider);

  // 1. Filter
  List<ProductMock> result = products;
  if (filter == ProductFilterType.expired) {
    result = products.where((p) => p.isExpired).toList();
  } else if (filter == ProductFilterType.lowStock) {
    result = products.where((p) => p.status == StockStatus.low || p.status == StockStatus.outOfStock).toList();
  }

  if (selectedCategory != null) {
    result = result.where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
  }


  // 2. Sort
  switch (sortType) {
    case ProductSortType.newestToOldest:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case ProductSortType.oldToNew:
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case ProductSortType.alphabeticalAZ:
      result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      break;
    case ProductSortType.alphabeticalZA:
      result.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      break;
    case ProductSortType.quantityHighToLow:
      result.sort((a, b) => b.qty.compareTo(a.qty));
      break;
    case ProductSortType.quantityLowToHigh:
      result.sort((a, b) => a.qty.compareTo(b.qty));
      break;
  }

  return result;
});

class SuppliersListNotifier extends StateNotifier<List<SupplierMock>> {
  final Ref _ref;

  SuppliersListNotifier(this._ref) : super([]) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    final session = _ref.read(sessionProvider);
    final businessId = session.user?.businessId;
    if (businessId == null || businessId.isEmpty) {
      state = [];
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .order('name', ascending: true);

      final fetchedList = (response as List).map((data) {
        return SupplierMock(
          id: data['id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          phone: data['phone']?.toString() ?? '',
          supplyValue: data['supply_value']?.toString() ?? '0',
          debtAmount: data['debt_amount']?.toString() ?? '0',
          purchases: const [],
        );
      }).toList();

      state = fetchedList.isEmpty ? _initialSuppliers : fetchedList;
    } catch (e) {
      state = _initialSuppliers;
    }
  }

  Future<SupplierMock?> addSupplier(String name, String phone) async {
    final session = _ref.read(sessionProvider);
    final businessId = session.user?.businessId;
    if (businessId == null || businessId.isEmpty) return null;

    try {
      final response = await Supabase.instance.client.from('suppliers').insert({
        'business_id': businessId,
        'name': name,
        'phone': phone.isEmpty ? 'Not set' : phone,
        'supply_value': 0,
        'debt_amount': 0,
      }).select().single();

      final newSupplier = SupplierMock(
        id: response['id']?.toString() ?? '',
        name: response['name']?.toString() ?? '',
        phone: response['phone']?.toString() ?? '',
        supplyValue: '0',
        debtAmount: '0',
        purchases: const [],
      );

      final currentList = state == _initialSuppliers ? <SupplierMock>[] : state;
      state = [...currentList, newSupplier];
      return newSupplier;
    } catch (e) {
      return null;
    }
  }
}

// Suppliers List Provider
final suppliersListProvider = StateNotifierProvider<SuppliersListNotifier, List<SupplierMock>>((ref) {
  return SuppliersListNotifier(ref);
});

