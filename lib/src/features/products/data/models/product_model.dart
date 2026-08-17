import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.sku,
    required super.category,
    required super.costPrice,
    required super.sellPrice,
    required super.quantity,
    required super.lowStockAt,
    required super.unit,
    super.expiryDate,
    super.rawSupplierId,
    super.rawSupplierName,
    super.halfUnitPrice,
    super.retailPrice,
    required super.createdAt,
    super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      businessId: map['business_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      costPrice: double.tryParse(map['cost_price']?.toString() ?? '') ?? 0.0,
      sellPrice: double.tryParse(map['sell_price']?.toString() ?? '') ?? 0.0,
      quantity: double.tryParse(map['quantity']?.toString() ?? '') ?? 0.0,
      lowStockAt: double.tryParse(map['low_stock_at']?.toString() ?? '') ?? 0.0,
      unit: map['unit']?.toString() ?? 'pcs',
      expiryDate: map['expiry_date'] != null ? DateTime.tryParse(map['expiry_date'].toString()) : null,
      rawSupplierId: map['supplier_id']?.toString(),
      rawSupplierName: map['supplier_name']?.toString() ?? map['supplier']?.toString(),
      halfUnitPrice: (map['half_unit_price'] as num?)?.toDouble(),
      retailPrice: (map['retail_price'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null 
          ? (DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.tryParse(map['updated_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'sku': sku,
      'category': category,
      'cost_price': costPrice,
      'sell_price': sellPrice,
      'quantity': quantity,
      'low_stock_at': lowStockAt,
      'unit': unit,
      'expiry_date': expiryDate?.toIso8601String(),
      'supplier_id': rawSupplierId,
      'supplier_name': rawSupplierName,
      'half_unit_price': halfUnitPrice,
      'retail_price': retailPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
