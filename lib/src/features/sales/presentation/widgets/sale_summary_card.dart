import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleSummaryCard extends StatelessWidget {
  final String paymentStatus;

  const SaleSummaryCard({super.key, required this.paymentStatus});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = paymentStatus == 'Paid';
    final bool isPartial = paymentStatus == 'Partial';

    final Color statusBg = isPaid
        ? const Color(0xFFECFDF5)
        : isPartial
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFFEE2E2);

    final Color statusText = isPaid
        ? const Color(0xFF059669)
        : isPartial
            ? const Color(0xFFD97706)
            : const Color(0xFFDC2626);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          // Invoice Header
          Container(
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
                  '# BZ08252819',
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
          
          // Details Rows
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildDetailRow('Date', 'Jun 17, 2026 17:45'),
                SizedBox(height: 14.h),
                _buildCustomerRow(isPaid: isPaid),
                SizedBox(height: 14.h),
                _buildDetailRowWithPill('Sale status', paymentStatus, statusBg, statusText),
                SizedBox(height: 14.h),
                _buildDetailRow('Payment method', isPaid ? 'Bank Transfer' : 'None', isValueGray: true),
                SizedBox(height: 14.h),
                _buildDetailRow('Staff', 'gnade', isValueBold: true),
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
                  '₦ ${(isPaid ? 0 : 105887.50).toStringAsFixed(2)}',
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
              'Musa Abubakar',
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
}
