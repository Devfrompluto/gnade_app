import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';
import '../widgets/purchase_metadata_card.dart';
import '../widgets/purchase_products_list.dart';
import '../widgets/purchase_totals_card.dart';

class PurchaseDetailsScreen extends ConsumerWidget {
  final String id;

  const PurchaseDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersListProvider);
    SupplierMock? supplier;
    SupplierPurchaseMock? purchase;

    for (final s in suppliers) {
      for (final p in s.purchases) {
        final cleanPId = p.id.startsWith('#') ? p.id.substring(1) : p.id;
        if (cleanPId == id) {
          supplier = s;
          purchase = p;
          break;
        }
      }
      if (purchase != null) break;
    }

    if (purchase == null || supplier == null) {
      return Scaffold(
        appBar: AppCustomAppBar(
          title: 'Purchase details',
          onBackPressed: () => context.pop(),
        ),
        body: Center(
          child: Text(
            'Purchase not found.',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // light slate gray background
      appBar: AppCustomAppBar(
        title: 'Purchase details',
        onBackPressed: () => context.pop(),
        actions: [
          GestureDetector(
            onTap: () => showGlobalToast(message: 'Delete purchase coming soon'),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2), // soft red circle
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFDC2626),
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // 1. Metadata Card Component
            PurchaseMetadataCard(
              purchase: purchase,
              supplierName: supplier.name,
            ),
            SizedBox(height: 16.h),

            // 2. Products List Component
            PurchaseProductsList(items: purchase.items),
            SizedBox(height: 16.h),

            // 3. Pricing Calculations Component
            PurchaseTotalsCard(purchase: purchase),
          ],
        ),
      ),
    );
  }
}
