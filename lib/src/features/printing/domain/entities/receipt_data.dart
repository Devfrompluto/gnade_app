class ReceiptItem {
  final String name;
  final double quantity;
  final double unitPrice;
  final double total;

  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

class ReceiptData {
  final String businessName;
  final String businessAddress;
  final String businessPhone;
  final String? businessEmail;
  final String invoiceNo;
  final DateTime dateTime;
  final String customerName;
  final String customerType;
  final List<ReceiptItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final double amountPaid;
  final String paymentMethod;
  /// 'Paid' | 'Partial' | 'Unpaid'
  final String paymentStatus;
  bool get isPaid => paymentStatus == 'Paid';

  const ReceiptData({
    required this.businessName,
    required this.businessAddress,
    required this.businessPhone,
    this.businessEmail,
    required this.invoiceNo,
    required this.dateTime,
    required this.customerName,
    required this.customerType,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.amountPaid,
    required this.paymentMethod,
    required this.paymentStatus,
  });
}
