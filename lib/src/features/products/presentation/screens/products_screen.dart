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

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(productsLayoutProvider);
    final sortedProducts = ref.watch(filteredSortedProductsProvider);

    // Apply local search filtering
    final displayProducts = _searchQuery.isEmpty
        ? sortedProducts
        : sortedProducts
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.sku.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: _isSearching ? 12.w : 16.w,
        title: _isSearching
            ? Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                          ),
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 18.sp),
                      onPressed: () {
                        if (_searchQuery.isNotEmpty) {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        } else {
                          setState(() {
                            _isSearching = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              )
            : Text(
                'Products',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 22.sp,
                ),
              ),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF0F172A),
                    size: 24.sp,
                  ),
                  onPressed: () => setState(() => _isSearching = true),
                ),
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
            child: RefreshIndicator(
              color: const Color(0xFF2563EB),
              onRefresh: () async {
                if (!await requireConnectivity()) return;
                await ref.read(productsListProvider.notifier).loadProducts();
                await ref.read(categoriesProvider.notifier).loadCategories();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                      child: displayProducts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Text(
                                  'No items found',
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          : layout == ProductLayoutType.list
                              ? Column(
                                  children: displayProducts.map((product) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 12.h),
                                      child: InventoryItemTile(
                                        name: product.name,
                                        qty: product.qty,
                                        price: NumberFormat('#,##0').format(product.price),
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
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12.w,
                                    mainAxisSpacing: 12.h,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: displayProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = displayProducts[index];
                                    return InventoryItemGridTile(
                                      name: product.name,
                                      qty: product.qty,
                                      price: NumberFormat('#,##0').format(product.price),
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
          ),
          const ProductsBottomActions(),
        ],
      ),
    );
  }
}
