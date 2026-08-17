import '../../domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  const SaleItemModel({
    required super.id,
    required super.saleId,
    super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.total,
    super.priceType,
  });

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id']?.toString() ?? '',
      saleId: map['sale_id']?.toString() ?? '',
      productId: map['product_id']?.toString(),
      productName: map['product_name']?.toString() ?? '',
      quantity: double.tryParse(map['quantity']?.toString() ?? '') ?? 0.0,
      unitPrice: double.tryParse(map['unit_price']?.toString() ?? '') ?? 0.0,
      total: double.tryParse(map['total']?.toString() ?? '') ?? 0.0,
      priceType: (map['price_type'] as String?) ?? 'wholesale',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total': total,
      'price_type': priceType,
    };
  }
}
