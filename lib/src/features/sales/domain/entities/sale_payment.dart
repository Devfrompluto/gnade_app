import 'package:equatable/equatable.dart';

class SalePayment extends Equatable {
  final String id;
  final String saleId;
  final String? businessId;
  final double amount;
  final String paymentMethod;
  final String type; // 'payment' or 'refund'
  final String? note;
  final DateTime createdAt;

  const SalePayment({
    required this.id,
    required this.saleId,
    this.businessId,
    required this.amount,
    required this.paymentMethod,
    required this.type,
    this.note,
    required this.createdAt,
  });

  bool get isPayment => type.toLowerCase() == 'payment';
  bool get isRefund => type.toLowerCase() == 'refund';

  @override
  List<Object?> get props => [
        id,
        saleId,
        businessId,
        amount,
        paymentMethod,
        type,
        note,
        createdAt,
      ];
}
