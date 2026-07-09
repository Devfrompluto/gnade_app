import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String? productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double total;

  const SaleItem({
    required this.id,
    required this.saleId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        productName,
        quantity,
        unitPrice,
        total,
      ];
}
