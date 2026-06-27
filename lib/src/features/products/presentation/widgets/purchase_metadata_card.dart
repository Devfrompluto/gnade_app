import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class PurchaseMetadataCard extends StatelessWidget {
  final SupplierPurchaseMock purchase;
  final String supplierName;

  const PurchaseMetadataCard({
    super.key,
    required this.purchase,
    required this.supplierName,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = purchase.status == 'Credit';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with ID and Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '# ${purchase.id.startsWith('#') ? purchase.id.substring(1) : purchase.id}',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                ),
              ),
              IconButton(
                icon: Icon(Icons.content_copy_outlined, color: const Color(0xFF64748B), size: 18.sp),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: purchase.id));
                  showGlobalToast(message: 'Invoice ID copied');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 16.h),

          // Date Row
          _buildDetailRow(
            label: 'Date',
            value: purchase.date,
          ),
          SizedBox(height: 14.h),

          // Supplier Row
          _buildDetailRow(
            label: 'Supplier',
            value: supplierName,
            valueStyle: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 14.h),

          // Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Purchase status',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
              Row(
                children: [
                  if (isCredit) ...[
                    GestureDetector(
                      onTap: () => showGlobalToast(message: 'Pay debt coming soon'),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // soft blue background
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Pay debt',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: isCredit ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      purchase.status,
                      style: TextStyle(
                        color: isCredit ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Staff Row
          _buildDetailRow(
            label: 'Staff',
            value: purchase.staff,
          ),
          SizedBox(height: 14.h),

          // Amount Paid Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount paid',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
              Text(
                purchase.status == 'Paid' ? '₦${purchase.totalAmount}' : '0',
                style: TextStyle(
                  color: purchase.status == 'Paid' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
        ),
      ],
    );
  }
}
