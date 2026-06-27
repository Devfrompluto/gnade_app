import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class SupplierPurchaseCard extends StatelessWidget {
  final SupplierPurchaseMock purchase;
  final String supplierName;

  const SupplierPurchaseCard({
    super.key,
    required this.purchase,
    required this.supplierName,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = purchase.status == 'Credit';
    final cleanId = purchase.id.startsWith('#') ? purchase.id.substring(1) : purchase.id;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'purchaseDetails',
          pathParameters: {'id': cleanId},
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                purchase.id,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCredit ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  purchase.status,
                  style: TextStyle(
                    color: isCredit ? const Color(0xFFDC2626) : const Color(0xFF059669),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Items description row
          Text(
            purchase.itemsSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 12.h),

          // Totals and Balance Due
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '₦${purchase.totalAmount}',
                    style: TextStyle(
                      color: const Color(0xFF2563EB), // blue for Total
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              // Balance due column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BALANCE DUE',
                    style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    purchase.balanceDue == '0' ? '₦0' : '₦${purchase.balanceDue}',
                    style: TextStyle(
                      color: isCredit ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 8.h),

          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Small avatar circle
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F2C59),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        supplierName.isNotEmpty ? supplierName[0].toUpperCase() : 'S',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 8.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    supplierName,
                    style: TextStyle(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              Text(
                purchase.date,
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
