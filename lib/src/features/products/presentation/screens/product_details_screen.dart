import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../providers/products_providers.dart';
import '../widgets/product_banner_card.dart';
import '../widgets/product_sales_summary_card.dart';
import '../widgets/product_info_card.dart';
import '../widgets/stock_movements_card.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String id;

  const ProductDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);
    final sessionState = ref.watch(sessionProvider);
    final isStaff = sessionState.user?.role == 'staff';

    Product? foundProduct;
    for (final p in products) {
      if (p.id == id) {
        foundProduct = p;
        break;
      }
    }

    final product = foundProduct ??
        (products.isNotEmpty
            ? products.first
            : Product(
                id: id,
                businessId: sessionState.user?.businessId ?? '',
                name: 'Product',
                sku: 'SKU-000',
                category: 'General',
                costPrice: 0,
                sellPrice: 0,
                quantity: 0,
                lowStockAt: 5,
                unit: 'pcs',
                createdAt: DateTime.now(),
              ));

    final unit = product.unit.isNotEmpty ? product.unit : 'pcs';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: 'Product Details',
        onBackPressed: () => context.pop(),
        actions: [
          if (!isStaff) ...[
            // + Add Stock Pill Button — navigates to full screen
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addStock, extra: product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E40AF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                icon: Icon(Icons.add, size: 16.sp),
                label: Text(
                  'Add Stock',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 6.w),

            // Edit Icon
            IconButton(
              icon: Icon(Icons.edit_outlined, color: const Color(0xFF0F172A), size: 20.sp),
              onPressed: () => context.push(AppRoutes.editProduct, extra: product),
            ),

            // Overflow Options Menu
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF0F172A), size: 20.sp),
              onSelected: (value) {
                if (value == 'delete') {
                  showGlobalToast(message: 'Delete product coming soon');
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete Product', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductBannerCard(product: product, unit: unit),
            SizedBox(height: 14.h),
            if (!isStaff) ...[
              ProductSalesSummaryCard(product: product, unit: unit),
              SizedBox(height: 14.h),
            ],
            ProductInfoCard(product: product, unit: unit, isStaff: isStaff),
            SizedBox(height: 14.h),
            if (!isStaff) ...[
              StockMovementsCard(product: product),
              SizedBox(height: 30.h),
            ],
          ],
        ),
      ),
    );
  }
}
