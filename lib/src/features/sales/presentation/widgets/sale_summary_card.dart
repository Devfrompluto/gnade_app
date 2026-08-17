import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleSummaryCard extends StatelessWidget {
  final Sale sale;

  const SaleSummaryCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final rawStatus = sale.status.toLowerCase();
    String paymentStatus;
    Color statusBg;
    Color statusText;

    if (rawStatus == 'paid') {
      paymentStatus = 'Paid';
      statusBg = const Color(0xFFECFDF5);
      statusText = const Color(0xFF059669);
    } else if (rawStatus == 'refunded') {
      paymentStatus = 'Returned';
      statusBg = const Color(0xFFF3E8FF);
      statusText = const Color(0xFF9333EA);
    } else if (rawStatus == 'partial_refund') {
      paymentStatus = 'P. Returned';
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFFD97706);
    } else if (rawStatus == 'partial') {
      paymentStatus = 'Partial';
      statusBg = const Color(0xFFFFF7ED);
      statusText = const Color(0xFFD97706);
    } else {
      paymentStatus = 'Unpaid';
      statusBg = const Color(0xFFFEF2F2);
      statusText = const Color(0xFFDC2626);
    }

    final bool isPaid = rawStatus == 'paid';

    String displayPaymentMethod = sale.paymentMethod;
    if (displayPaymentMethod.toLowerCase() == 'cash') {
      displayPaymentMethod = 'Cash';
    } else if (displayPaymentMethod.toLowerCase() == 'bank' || displayPaymentMethod.toLowerCase() == 'transfer') {
      displayPaymentMethod = 'Bank Transfer';
    } else if (displayPaymentMethod.toLowerCase() == 'mobile') {
      displayPaymentMethod = 'Mobile Payment';
    } else if (displayPaymentMethod.toLowerCase() == 'credit') {
      displayPaymentMethod = 'Credit / Debt';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          // Invoice Header
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: sale.invoiceNo));
              showGlobalToast(message: 'Invoice number copied to clipboard!');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11.r)),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '# ${sale.invoiceNo}',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                  Icon(
                    Icons.copy_outlined,
                    color: const Color(0xFF3B82F6),
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          
          // Details Rows
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildDetailRow('Date', DateFormat('MMM dd, yyyy HH:mm').format(sale.createdAt)),
                SizedBox(height: 14.h),
                _buildCustomerRow(isPaid: isPaid),
                SizedBox(height: 14.h),
                _buildDetailRowWithPill('Sale status', paymentStatus, statusBg, statusText),
                SizedBox(height: 14.h),
                _buildPaymentMethodRow(context, sale.paymentMethod, displayPaymentMethod),
                SizedBox(height: 14.h),
                _buildDetailRow('Cashier', sale.cashier, isValueBold: true),
              ],
            ),
          ),
          
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          
          // Balance Amount Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance amount',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '₦ ${sale.balanceDue.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isPaid ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerRow({required bool isPaid}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Customer',
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 13.sp,
          ),
        ),
        Row(
          children: [
            if (!isPaid) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Remind',
                  style: TextStyle(
                    color: const Color(0xFF1D4ED8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Text(
              sale.customerName,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isValueGray = false, bool isValueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 13.sp,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isValueGray ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithPill(String label, String pillText, Color pillBgColor, Color pillTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 13.sp,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: pillBgColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            pillText,
            style: TextStyle(
              color: pillTextColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodRow(BuildContext context, String rawMethod, String defaultDisplay) {
    final isMultiple = rawMethod.toLowerCase().startsWith('multiple');
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: isMultiple ? () => _showMultipleBreakdownDialog(context, rawMethod) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Payment method',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 13.sp,
            ),
          ),
          Row(
            children: [
              Text(
                isMultiple ? 'Multiple' : defaultDisplay,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
              if (isMultiple) ...[
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Breakdown',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 11.sp,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showMultipleBreakdownDialog(BuildContext context, String methodStr) {
    final parts = <String, String>{};

    final matches = RegExp(r'([A-Za-z\s/]+):\s*(₦?\s*[\d,\.]+)').allMatches(methodStr);
    for (final match in matches) {
      final key = match.group(1)?.trim();
      var value = match.group(2)?.trim();
      if (value != null && value.endsWith(',')) {
        value = value.substring(0, value.length - 1).trim();
      }
      if (key != null && value != null && key.isNotEmpty && value.isNotEmpty) {
        parts[key] = value;
      }
    }

    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.call_split_rounded, color: primaryColor, size: 20.sp),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Payment Breakdown',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (parts.isNotEmpty)
                ...parts.entries.map((e) => Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                          ),
                          Text(
                            e.value,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ))
              else
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Recorded as Multiple Split Payment.\nDetails: $methodStr',
                    style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
                  ),
                ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}
