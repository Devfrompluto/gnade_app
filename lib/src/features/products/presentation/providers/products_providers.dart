import 'package:gnade_app/src/imports/imports.dart';
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

class ProductMock {
  final String id;
  final String name;
  final int qty;
  final String price; // String to match existing tile price format
  final int lowStockAt;
  final String sku;
  final String category;
  final String unit;
  final String supplier;
  final String supplierId;
  final String lastUpdated;
  final DateTime? expiryDate;
  final DateTime createdAt;

  const ProductMock({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.lowStockAt,
    required this.sku,
    required this.category,
    required this.unit,
    required this.supplier,
    required this.supplierId,
    required this.lastUpdated,
    this.expiryDate,
    required this.createdAt,
  });

  // Helper getter to calculate stock status dynamically
  StockStatus get status {
    if (qty == 0) return StockStatus.outOfStock;
    if (qty <= lowStockAt) return StockStatus.low;
    return StockStatus.inStock;
  }

  // Helper to check if it's expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}

// Initial mockup list
final _initialProducts = [
  ProductMock(
    id: '1',
    name: 'Tiger bottle',
    qty: 0,
    price: '1,200',
    lowStockAt: 5,
    sku: 'BZ_Prod1',
    category: 'Beverages',
    unit: 'bottle',
    supplier: 'Golden Breweries',
    supplierId: 's2',
    lastUpdated: 'Today, 10:15 AM',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  ProductMock(
    id: '2',
    name: 'Schweppes',
    qty: 0,
    price: '500',
    lowStockAt: 5,
    sku: 'BZ_Prod2',
    category: 'Beverages',
    unit: 'bottle',
    supplier: 'Coca Cola Hellenic',
    supplierId: 's3',
    lastUpdated: 'Yesterday, 04:30 PM',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  ProductMock(
    id: '3',
    name: 'Burst Berry',
    qty: 3,
    price: '800',
    lowStockAt: 5,
    sku: 'BZ_Prod3',
    category: 'Beverages',
    unit: 'pack',
    supplier: 'Chi Limited',
    supplierId: 's4',
    lastUpdated: 'Today, 11:20 AM',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ProductMock(
    id: '4',
    name: '5Alive',
    qty: 5,
    price: '1,500',
    lowStockAt: 10,
    sku: 'BZ_Prod4',
    category: 'Beverages',
    unit: 'carton',
    supplier: 'Chi Limited',
    supplierId: 's4',
    lastUpdated: 'Today, 02:10 PM',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ProductMock(
    id: '5',
    name: 'Coca Cola 50cl',
    qty: 48,
    price: '300',
    lowStockAt: 10,
    sku: 'BZ_Prod5',
    category: 'Beverages',
    unit: 'bottle',
    supplier: 'Coca Cola Hellenic',
    supplierId: 's3',
    lastUpdated: 'Today, 03:28 PM',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
  ),
  ProductMock(
    id: '6',
    name: 'Expired Milk',
    qty: 12,
    price: '2,400',
    lowStockAt: 5,
    sku: 'BZ_Prod6',
    category: 'Dairy',
    unit: 'pack',
    supplier: 'Promasidor',
    supplierId: 's6',
    lastUpdated: '2 days ago',
    expiryDate: DateTime.now().subtract(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ProductMock(
    id: '7',
    name: 'Pepsi 50cl',
    qty: 120,
    price: '350',
    lowStockAt: 15,
    sku: 'BZ_Prod7',
    category: 'Beverages',
    unit: 'bottle',
    supplier: 'Seven-Up Bottling',
    supplierId: 's5',
    lastUpdated: 'Today, 04:45 PM',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  ProductMock(
    id: '8',
    name: 'Can Fanta',
    qty: 2,
    price: '450',
    lowStockAt: 5,
    sku: 'BZ_Prod8',
    category: 'Cans',
    unit: 'Can',
    supplier: 'Senna Atlantic',
    supplierId: 's1',
    lastUpdated: 'Today, 03:28 PM',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
];

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
final productsListProvider = StateNotifierProvider<ProductsListNotifier, List<ProductMock>>((ref) {
  return ProductsListNotifier();
});

class ProductsListNotifier extends StateNotifier<List<ProductMock>> {
  ProductsListNotifier() : super(_initialProducts);

  void addProduct(ProductMock product) {
    state = [...state, product];
  }
}

// Filtered and Sorted Products Provider
final filteredSortedProductsProvider = Provider<List<ProductMock>>((ref) {
  final products = ref.watch(productsListProvider);
  final filter = ref.watch(productsFilterProvider);
  final sortType = ref.watch(productsSortProvider);

  // 1. Filter
  List<ProductMock> result = products;
  if (filter == ProductFilterType.expired) {
    result = products.where((p) => p.isExpired).toList();
  } else if (filter == ProductFilterType.lowStock) {
    result = products.where((p) => p.status == StockStatus.low || p.status == StockStatus.outOfStock).toList();
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

// Suppliers List Provider
final suppliersListProvider = StateProvider<List<SupplierMock>>((ref) {
  return _initialSuppliers;
});

