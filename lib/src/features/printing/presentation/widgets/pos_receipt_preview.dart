import 'package:gnade_app/src/imports/imports.dart';

class POSReceiptPreview extends StatelessWidget {
  final ReceiptData data;

  const POSReceiptPreview({
    super.key,
    required this.data,
  });

  String _formatDate(DateTime dt) {
    return DateFormat('dd–MM–yy, HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290.w,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Blue circle with mini cart bag
          Center(
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 22.sp,
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),

          // Business Address
          Center(
            child: Text(
              data.businessAddress,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Business Phone
          Center(
            child: Text(
              'Tel: ${data.businessPhone}',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 12.h),

          // Metadata Rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaLabelValue('INVOICE #', data.invoiceNo),
              _buildMetaLabelValue('DATE', _formatDate(data.dateTime)),
            ],
          ),
          SizedBox(height: 10.h),
          _buildMetaLabelValue('CUSTOMER', data.customerName),
          SizedBox(height: 14.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 10.h),

          // Items Table Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'ITEM',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'QTY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'PRICE',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 8.h),

          // Items List
          ...data.items.map((item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.name,
                        style: TextStyle(
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        item.quantity.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₦${item.total.toStringAsFixed(0)}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 12.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 10.h),

          // Subtotal, Tax, Total
          if (data.subtotal > 0)
            _buildSummaryRow('Subtotal', '₦${data.subtotal.toStringAsFixed(0)}'),
          if (data.subtotal > 0)
            SizedBox(height: 6.h),
          if (data.tax > 0)
            _buildSummaryRow('Tax (7.5% VAT)', '₦${data.tax.toStringAsFixed(0)}'),
          if (data.tax > 0)
            SizedBox(height: 12.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 12.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                '₦${data.total.toStringAsFixed(0)}',
                style: TextStyle(
                  color: const Color(0xFF0F9F68),
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),

          // Amount Paid / Balance Owed for Partial/Unpaid
          if (data.paymentStatus == 'Partial') ...[
            SizedBox(height: 8.h),
            _buildSummaryRow('Amount Paid', '₦${data.amountPaid.toStringAsFixed(0)}'),
            SizedBox(height: 4.h),
            _buildSummaryRow(
                'Balance Owed', '₦${(data.total - data.amountPaid).toStringAsFixed(0)}'),
          ] else if (data.paymentStatus == 'Unpaid') ...[
            SizedBox(height: 8.h),
            _buildSummaryRow('Amount Paid', '₦0'),
            SizedBox(height: 4.h),
            _buildSummaryRow('Balance Owed (Debt)', '₦${data.total.toStringAsFixed(0)}'),
          ],
          SizedBox(height: 16.h),

          // Dotted Divider
          CustomPaint(
            size: Size(double.infinity, 1.h),
            painter: DashedDividerPainter(),
          ),
          SizedBox(height: 14.h),

          // Payment Status Badge
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: data.paymentStatus == 'Paid'
                    ? const Color(0xFFECFDF5)
                    : data.paymentStatus == 'Partial'
                        ? const Color(0xFFFFF7ED)
                        : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    data.paymentStatus == 'Paid'
                        ? Icons.check_circle_rounded
                        : data.paymentStatus == 'Partial'
                            ? Icons.timelapse_rounded
                            : Icons.warning_amber_rounded,
                    color: data.paymentStatus == 'Paid'
                        ? const Color(0xFF059669)
                        : data.paymentStatus == 'Partial'
                            ? const Color(0xFFD97706)
                            : const Color(0xFFDC2626),
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    data.paymentStatus == 'Paid'
                        ? 'PAID IN FULL'
                        : data.paymentStatus == 'Partial'
                            ? 'PARTIAL PAYMENT'
                            : 'OUTSTANDING DEBT',
                    style: TextStyle(
                      color: data.paymentStatus == 'Paid'
                          ? const Color(0xFF059669)
                          : data.paymentStatus == 'Partial'
                              ? const Color(0xFFD97706)
                              : const Color(0xFFDC2626),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Footnote
          Center(
            child: Text(
              'Thank you for your business!',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 10.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF94A3B8),
            fontWeight: FontWeight.w800,
            fontSize: 7.sp,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.bold,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 10.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }
}
