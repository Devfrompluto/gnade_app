import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';
import 'supplier_purchase_card.dart';

class SupplierPurchasesList extends StatelessWidget {
  final SupplierMock supplier;

  const SupplierPurchasesList({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recent Purchases Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Purchases',
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
              ),
            ),
            GestureDetector(
              onTap: () => showGlobalToast(message: 'View All purchases coming soon'),
              child: Text(
                'View All',
                style: TextStyle(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Purchases list
        if (supplier.purchases.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'No recent purchases recorded.',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          Column(
            children: supplier.purchases.map((purchase) {
              return SupplierPurchaseCard(
                purchase: purchase,
                supplierName: supplier.name,
              );
            }).toList(),
          ),
      ],
    );
  }
}
