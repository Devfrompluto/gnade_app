import '../../domain/entities/sale.dart';
import 'sale_item_model.dart';

class SaleModel extends Sale {
  const SaleModel({
    required super.id,
    required super.businessId,
    required super.customerName,
    required super.totalAmount,
    required super.amountPaid,
    required super.discount,
    required super.paymentMethod,
    required super.status,
    required super.invoiceNo,
    required super.createdAt,
    super.items,
  });

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    List<SaleItemModel>? mappedItems;
    if (map['sale_items'] != null) {
      mappedItems = (map['sale_items'] as List)
          .map((item) => SaleItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return SaleModel(
      id: map['id']?.toString() ?? '',
      businessId: map['business_id']?.toString() ?? '',
      customerName: map['customer_name']?.toString() ?? 'None',
      totalAmount: double.tryParse(map['total_amount']?.toString() ?? '') ?? 0.0,
      amountPaid: double.tryParse(map['amount_paid']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(map['discount']?.toString() ?? '') ?? 0.0,
      paymentMethod: map['payment_method']?.toString() ?? 'CASH',
      status: map['status']?.toString() ?? 'paid',
      invoiceNo: map['invoice_no']?.toString() ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
      items: mappedItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'discount': discount,
      'payment_method': paymentMethod,
      'status': status,
      'invoice_no': invoiceNo,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
