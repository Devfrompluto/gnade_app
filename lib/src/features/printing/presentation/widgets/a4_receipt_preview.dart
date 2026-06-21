import 'package:gnade_app/src/imports/imports.dart';

class A4ReceiptPreview extends StatelessWidget {
  final ReceiptData data;

  const A4ReceiptPreview({
    super.key,
    required this.data,
  });

  String _formatFullDate(DateTime dt) {
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  String _formatTime(DateTime dt) {
    return '${DateFormat('HH:mm').format(dt)} WAT';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Blue circle with mini storefront
          Center(
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Business Name
          Center(
            child: Text(
              data.businessName,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(height: 6.h),

          // Business Address & Contact Info
          Center(
            child: Text(
              '123 Trade Center Way, Victoria Island, Lagos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Center(
            child: Text(
              'Tel: ${data.businessPhone} | Email: ${data.businessEmail ?? 'contact@gnademulticoncept.com'}',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Double thick divider line
          Container(
            height: 2.h,
            width: double.infinity,
            color: const Color(0xFF1E293B),
          ),
          SizedBox(height: 18.h),

          // Metadata block & Billed to Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left block: Invoice Title and Metadata
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INVOICE',
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildA4MetaLabelValue('INVOICE NO:', 'INV-47-2023X'),
                  SizedBox(height: 4.h),
                  _buildA4MetaLabelValue('DATE:', _formatFullDate(data.dateTime)),
                  SizedBox(height: 4.h),
                  _buildA4MetaLabelValue('TIME:', _formatTime(data.dateTime)),
                ],
              ),

              // Right block: Billed to Card
              Container(
                width: 130.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BILLED TO:',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 8.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      data.customerName,
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      data.customerType,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Items Table
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Text(
                      'ITEM DESCRIPTION',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w800,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w800,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'UNIT PRICE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w800,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'TOTAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w800,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Items rows
          ...data.items.map((item) => Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.quantity.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₦${item.unitPrice.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₦${item.total.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 24.h),

          // Slanted status stamp & Totals block row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status Stamp on the left
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: data.paymentStatus == 'Paid'
                              ? const Color(0xFF10B981)
                              : data.paymentStatus == 'Partial'
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFFDC2626),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          data.paymentStatus == 'Paid'
                              ? 'PAID IN FULL'
                              : data.paymentStatus == 'Partial'
                                  ? 'PARTIAL PAYMENT'
                                  : 'OUTSTANDING DEBT',
                          style: TextStyle(
                            color: data.paymentStatus == 'Paid'
                                ? const Color(0xFF10B981)
                                : data.paymentStatus == 'Partial'
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFFDC2626),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Totals Block on the right
              Container(
                width: 160.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFEFF6FF),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildA4TotalsRow('Subtotal', '₦${data.subtotal.toStringAsFixed(0)}'),
                    if (data.tax > 0) ...[
                      SizedBox(height: 6.h),
                      _buildA4TotalsRow('Tax (7.5% VAT)', '₦${data.tax.toStringAsFixed(0)}'),
                    ],
                    SizedBox(height: 8.h),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 10.sp,
                          ),
                        ),
                        Text(
                          '₦${data.total.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    if (data.paymentStatus == 'Partial') ...[
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      SizedBox(height: 6.h),
                      _buildA4TotalsRow('Amount Paid', '₦${data.amountPaid.toStringAsFixed(0)}'),
                      SizedBox(height: 4.h),
                      _buildA4TotalsRow(
                          'Balance Owed',
                          '₦${(data.total - data.amountPaid).toStringAsFixed(0)}'),
                    ] else if (data.paymentStatus == 'Unpaid') ...[
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      SizedBox(height: 6.h),
                      _buildA4TotalsRow('Amount Paid', '₦0'),
                      SizedBox(height: 4.h),
                      _buildA4TotalsRow('Outstanding Debt',
                          '₦${data.total.toStringAsFixed(0)}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),

          // Thick divider
          Container(
            height: 1.h,
            width: double.infinity,
            color: const Color(0xFFE2E8F0),
          ),
          SizedBox(height: 16.h),

          // Policy footprint
          Center(
            child: Text(
              'Thank you for your business!',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Center(
            child: Text(
              'Items purchased in good condition cannot be returned after 7 days. Please present this original receipt for any exchanges or claims. All transactions are subject to our standard terms and conditions available in-store or online.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 8.sp,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildA4MetaLabelValue(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildA4TotalsRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 9.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
          ),
        ),
      ],
    );
  }
}
