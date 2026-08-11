import '../../domain/entities/sale_payment.dart';

class SalePaymentModel extends SalePayment {
  const SalePaymentModel({
    required super.id,
    required super.saleId,
    super.businessId,
    required super.amount,
    required super.paymentMethod,
    required super.type,
    super.note,
    required super.createdAt,
  });

  factory SalePaymentModel.fromMap(Map<String, dynamic> map) {
    return SalePaymentModel(
      id: map['id']?.toString() ?? '',
      saleId: map['sale_id']?.toString() ?? '',
      businessId: map['business_id']?.toString(),
      amount: double.tryParse(map['amount']?.toString() ?? '') ?? 0.0,
      paymentMethod: map['payment_method']?.toString() ?? 'cash',
      type: map['type']?.toString() ?? 'payment',
      note: map['note']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      if (businessId != null) 'business_id': businessId,
      'amount': amount,
      'payment_method': paymentMethod,
      'type': type,
      if (note != null) 'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
