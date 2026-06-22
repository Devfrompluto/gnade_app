import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';
import '../widgets/inventory_item_tile.dart'; // to access StockStatus

class ProductDetailsScreen extends ConsumerWidget {
  final String id;

  const ProductDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsListProvider);
    final product = products.firstWhere(
      (p) => p.id == id,
      orElse: () => products.first,
    );

    // Stock alert logic
    Color alertBgColor;
    Color alertBorderColor;
    Color alertTextColor;
    IconData alertIcon;
    String alertText;

    switch (product.status) {
      case StockStatus.outOfStock:
        alertBgColor = const Color(0xFFFEF2F2); // Red-50
        alertBorderColor = const Color(0xFFFEE2E2); // Red-100
        alertTextColor = const Color(0xFFDC2626); // Red-600
        alertIcon = Icons.error_outline_rounded;
        alertText = 'Out of stock (Restock required)';
        break;
      case StockStatus.low:
        alertBgColor = const Color(0xFFFEF2F2); // Red-50 (Matches mockup)
        alertBorderColor = const Color(0xFFFEE2E2); // Red-100
        alertTextColor = const Color(0xFFDC2626); // Red-600
        alertIcon = Icons.warning_amber_rounded;
        alertText = 'Low stock (Reorder now)';
        break;
      case StockStatus.inStock:
        alertBgColor = const Color(0xFFECFDF5); // Emerald-50
        alertBorderColor = const Color(0xFFD1FAE5); // Emerald-100
        alertTextColor = const Color(0xFF059669); // Emerald-600
        alertIcon = Icons.check_circle_outline_rounded;
        alertText = 'In stock (Good quantity)';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // very light gray backdrop
      appBar: AppCustomAppBar(
        title: 'Product details',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // Main Card Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Block
                  Center(
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F5A47), // Dark forest green
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Text(
                          product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 32.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Title Text
                  Center(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SKU Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // slate-100
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          product.sku,
                          style: TextStyle(
                            color: const Color(0xFF475569), // slate-600
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      // Category Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF), // indigo-50
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: const Color(0xFF3730A3), // indigo-800
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  SizedBox(height: 16.h),

                  // Stock Information
                  Text(
                    'Stock',
                    style: TextStyle(
                      color: const Color(0xFF64748B), // slate-500
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${product.qty.toDouble()} ${product.unit}',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Stock Warning Banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: alertBgColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: alertBorderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          alertIcon,
                          color: alertTextColor == const Color(0xFF059669)
                              ? const Color(0xFF059669)
                              : const Color(0xFFEA580C), // Orange warning for low
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            alertText,
                            style: TextStyle(
                              color: alertTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  SizedBox(height: 16.h),

                  // Supplier Row
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        color: const Color(0xFF475569),
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Supplier',
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed(
                            'supplierDetails',
                            pathParameters: {'id': product.supplierId},
                          );
                        },
                        child: Text(
                          product.supplier,
                          style: TextStyle(
                            color: const Color(0xFF2563EB), // Premium blue link style
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Metadata Update Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Log details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.lastUpdated,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),

                  // Decorative Barcode/Stripe container
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: const Color(0xFFCBD5E1),
                        size: 26.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
