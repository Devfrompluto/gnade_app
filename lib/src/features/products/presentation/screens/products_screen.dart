import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/products/presentation/widgets/products_filter_pills.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/products_summary_cards.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/products_categories_list.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/inventory_item_tile.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/inventory_item_grid_tile.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/products_bottom_actions.dart';
import 'package:gnade_app/src/features/products/presentation/widgets/products_menu_sheet.dart';
import 'package:gnade_app/src/features/products/presentation/providers/products_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(productsLayoutProvider);
    final sortedProducts = ref.watch(filteredSortedProductsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // very light gray
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'Products',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w900,
            fontSize: 22.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: const Color(0xFF0F172A),
              size: 24.sp,
            ),
            onPressed: () => ProductsMenuSheet.show(context),
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProductsFilterPills(),
                  SizedBox(height: 24.h),
                  const ProductsSummaryCards(),
                  SizedBox(height: 24.h),
                  const ProductsCategoriesList(),
                  SizedBox(height: 24.h),

                  // Inventory Items List Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Inventory Items',
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Items List or Grid
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: layout == ProductLayoutType.list
                        ? Column(
                            children: sortedProducts.map((product) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: InventoryItemTile(
                                  name: product.name,
                                  qty: product.qty,
                                  price: product.price,
                                  status: product.status,
                                  onTap: () {
                                    context.pushNamed(
                                      'productDetails',
                                      pathParameters: {'id': product.id},
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12.w,
                              mainAxisSpacing: 12.h,
                              childAspectRatio:
                                  1, // perfect square aspect ratio
                            ),
                            itemCount: sortedProducts.length,
                            itemBuilder: (context, index) {
                              final product = sortedProducts[index];
                              return InventoryItemGridTile(
                                name: product.name,
                                qty: product.qty,
                                price: product.price,
                                status: product.status,
                                onTap: () {
                                  context.pushNamed(
                                    'productDetails',
                                    pathParameters: {'id': product.id},
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const ProductsBottomActions(),
        ],
      ),
    );
  }
}
