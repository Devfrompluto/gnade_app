import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SalePaymentHistoryCard extends StatelessWidget {
  final Sale sale;

  const SalePaymentHistoryCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final payments = sale.payments ?? const [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.history_rounded,
                    color: const Color(0xFF1E40AF),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Payment History',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          if (payments.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              separatorBuilder: (context, index) => Column(
                children: [
                  SizedBox(height: 10.h),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SizedBox(height: 10.h),
                ],
              ),
              itemBuilder: (context, index) {
                final p = payments[index];
                final isPositive = p.amount >= 0;
                final formattedAmt = NumberFormat('#,##0.00').format(p.amount.abs());
                final amountStr = isPositive ? '+₦ $formattedAmt' : '-₦ $formattedAmt';

                return _buildHistoryItem(
                  title: p.isPayment ? (p.note ?? 'Payment Received') : (p.note ?? 'Refund Processed'),
                  subtitle: '${p.paymentMethod.toUpperCase()} • Cashier: ${sale.cashier}',
                  amount: amountStr,
                  date: DateFormat('MMM dd, yyyy HH:mm').format(p.createdAt),
                  isCredit: isPositive,
                  icon: isPositive ? Icons.payments_outlined : Icons.undo_rounded,
                );
              },
            ),
          ] else ...[
            // Fallback for legacy sales created before sale_payments table
            _buildHistoryItem(
              title: sale.amountPaid > 0 ? 'Initial Payment' : 'Debt Recorded',
              subtitle: '${sale.paymentMethod} • Cashier: ${sale.cashier}',
              amount: '₦ ${NumberFormat('#,##0.00').format(sale.amountPaid)}',
              date: DateFormat('MMM dd, yyyy HH:mm').format(sale.createdAt),
              isCredit: sale.amountPaid > 0,
              icon: sale.amountPaid > 0 ? Icons.payments_outlined : Icons.credit_card_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String subtitle,
    required String amount,
    required String date,
    required bool isCredit,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isCredit ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
              size: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: isCredit ? const Color(0xFF059669) : const Color(0xFFDC2626),
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
