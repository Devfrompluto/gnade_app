import 'package:gnade_app/src/imports/imports.dart';

class SalesSummary {
  final int count;
  final double totalAmount;
  final double grossProfit;

  const SalesSummary({
    required this.count,
    required this.totalAmount,
    required this.grossProfit,
  });
}

abstract class SalesRepository {
  FutureEither<List<Sale>> getSales({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
    String? status,
  });

  FutureEither<SalesSummary> getSalesSummary({
    required String businessId,
    required DateTime startDate,
    required DateTime endDate,
  });

  FutureEither<Sale> createSale({
    required String businessId,
    required String customerName,
    required double totalAmount,
    required double amountPaid,
    required double discount,
    required String paymentMethod,
    required String status,
    required String invoiceNo,
    required List<Map<String, dynamic>> items, // Each contains productId, productName, quantity, unitPrice, total
    String? cashierName,
  });

  FutureEither<Sale> getSaleDetails(String saleId);

  FutureEither<Sale> recordPayment({
    required String saleId,
    required double paymentAmount,
    required String paymentMethod,
    String? reference,
    DateTime? paymentDate,
  });

  FutureEither<Sale> refundSale({
    required String saleId,
    required List<Map<String, dynamic>> refundedItems,
    required bool isFullRefund,
    required String reason,
  });
}
