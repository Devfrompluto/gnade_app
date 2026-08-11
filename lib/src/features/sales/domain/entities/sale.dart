import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'sale_item.dart';
import 'sale_payment.dart';

class Sale extends Equatable {
  final String id;
  final String businessId;
  final String customerName;
  final double totalAmount;
  final double amountPaid;
  final double discount;
  final String paymentMethod; // cash | transfer | credit
  final String status; // paid | partial | debt
  final String invoiceNo;
  final DateTime createdAt;
  final String? cashierName;
  final List<SaleItem>? items;
  final List<SalePayment>? payments;

  const Sale({
    required this.id,
    required this.businessId,
    required this.customerName,
    required this.totalAmount,
    required this.amountPaid,
    required this.discount,
    required this.paymentMethod,
    required this.status,
    required this.invoiceNo,
    required this.createdAt,
    this.cashierName,
    this.items,
    this.payments,
  });

  bool get isPaid => status.toLowerCase() == 'paid';
  
  double get balanceDue => totalAmount - amountPaid;

  // Compatibility getters for SaleCard
  String get invoice => invoiceNo;
  String get time => DateFormat('hh:mm a').format(createdAt);
  String get cashier => (cashierName != null && cashierName!.trim().isNotEmpty) ? cashierName! : 'Staff';
  String get amount => '₦ ${NumberFormat('#,##0').format(totalAmount)}';
  String get customer => customerName;
  String get date => DateFormat('MMM d, yyyy • HH:mm').format(createdAt);

  @override
  List<Object?> get props => [
        id,
        businessId,
        customerName,
        totalAmount,
        amountPaid,
        discount,
        paymentMethod,
        status,
        invoiceNo,
        createdAt,
        cashierName,
        items,
      ];
}

typedef SaleMock = Sale;
