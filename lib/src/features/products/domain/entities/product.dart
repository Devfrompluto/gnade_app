import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../presentation/widgets/inventory_item_tile.dart'; // Import StockStatus

class Product extends Equatable {
  final String id;
  final String businessId;
  final String name;
  final String sku;
  final String category;
  final double costPrice;
  final double sellPrice;
  final double quantity;
  final double lowStockAt;
  final String unit;
  final DateTime? expiryDate;
  final String? rawSupplierId;
  final String? rawSupplierName;
  final double? halfUnitPrice;
  final double? retailPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.sku,
    required this.category,
    required this.costPrice,
    required this.sellPrice,
    required this.quantity,
    required this.lowStockAt,
    required this.unit,
    this.expiryDate,
    this.rawSupplierId,
    this.rawSupplierName,
    this.halfUnitPrice,
    this.retailPrice,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isLowStock => quantity <= lowStockAt;
  bool get isOutOfStock => quantity <= 0;

  /// Whether this product has a half-unit price set
  bool get hasHalfUnit => halfUnitPrice != null && halfUnitPrice! > 0;

  /// Whether this product has a retail price set
  bool get hasRetailPrice => retailPrice != null && retailPrice! > 0;

  /// Returns available price types for this product
  List<String> get availablePriceTypes => const ['wholesale', 'retail'];

  // Compatibility fields for unmigrated product screens and POS
  int get qty => quantity.toInt();
  double get price => sellPrice;
  double get quantityInStock => quantity;
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  
  StockStatus get status {
    if (quantity <= 0) return StockStatus.outOfStock;
    if (quantity <= lowStockAt) return StockStatus.low;
    return StockStatus.inStock;
  }

  String get supplier => (rawSupplierName != null && rawSupplierName!.isNotEmpty) ? rawSupplierName! : 'None';
  String get supplierId => rawSupplierId ?? '';
  DateTime get displayUpdatedAt => updatedAt ?? createdAt;
  String get lastUpdated => DateFormat('dd MMM yyyy').format(displayUpdatedAt);

  String get initials {
    if (name.isEmpty) return '';
    return name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  Color get initialsColor {
    final colors = [
      const Color(0xFF1E3A8A), // Deep Slate/Navy
      const Color(0xFF10B981), // Emerald
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF0D9488), // Teal
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        sku,
        category,
        costPrice,
        sellPrice,
        quantity,
        lowStockAt,
        unit,
        expiryDate,
        rawSupplierId,
        rawSupplierName,
        halfUnitPrice,
        retailPrice,
        createdAt,
        updatedAt,
      ];
}

typedef ProductMock = Product;
typedef ProductItemMock = Product;
