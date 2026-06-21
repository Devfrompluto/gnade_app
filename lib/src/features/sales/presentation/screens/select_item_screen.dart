import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../widgets/product_item_tile.dart';

class SelectItemScreen extends StatefulWidget {
  const SelectItemScreen({super.key});

  @override
  State<SelectItemScreen> createState() => _SelectItemScreenState();
}

class _SelectItemScreenState extends State<SelectItemScreen> {
  String _searchQuery = '';
  int _selectedCategoryIndex = 0; // 0: All, 1: Cans, 2: Bottles, 3: PET
  
  // Track selected quantities for each product
  final Map<String, int> _selectedQuantities = {};

  final List<ProductItemMock> _products = [
    ProductItemMock(
      id: 'p1',
      name: 'Premium Rice 50kg',
      category: 'PET',
      initials: 'P',
      initialsColor: const Color(0xFF0F2C59), // Deep Blue
      quantityInStock: 10,
      price: 45000,
    ),
    ProductItemMock(
      id: 'p2',
      name: 'Vegetable Oil 5L',
      category: 'PET',
      initials: 'V',
      initialsColor: const Color(0xFF0D9488), // Teal
      quantityInStock: 5,
      price: 8500,
    ),
    ProductItemMock(
      id: 'p3',
      name: 'Burst Berry drink',
      category: 'PET',
      initials: 'B',
      initialsColor: const Color(0xFF7C3AED), // Purple
      quantityInStock: 10,
      price: 1500,
    ),
    ProductItemMock(
      id: 'p4',
      name: 'Star radler bottle',
      category: 'Bottles',
      initials: 'S',
      initialsColor: const Color(0xFF475569), // Slate
      quantityInStock: 0,
      price: 2000,
    ),
    ProductItemMock(
      id: 'p5',
      name: 'Tiger bottle',
      category: 'Bottles',
      initials: 'T',
      initialsColor: const Color(0xFF0D9488), // Teal
      quantityInStock: 0,
      price: 2200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Filter products by search query and category
    final categories = ['All', 'Cans', 'Bottles', 'PET'];
    final selectedCategory = categories[_selectedCategoryIndex];

    final filteredProducts = _products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || p.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    final int totalItemsSelected = _selectedQuantities.values.fold(0, (sum, qty) => sum + qty);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select item',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 16.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: Column(
          children: [
            // ─── Search Bar Row ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(AppSpacing.pagePadding.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13.sp,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 18.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Scanner button
                  Container(
                    width: 40.h,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF), // soft blue background
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: const Color(0xFF1E40AF), // Deep Blue
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Horizontal Category List ────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
              child: Row(
                children: List.generate(categories.length, (index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16.h),

            // ─── Products List ───────────────────────────────────────────────
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        final selectedQty = _selectedQuantities[product.id] ?? 0;

                        return ProductItemTile(
                          product: product,
                          selectedQty: selectedQty,
                          onAdd: () {
                            setState(() {
                              if (selectedQty < product.quantityInStock) {
                                _selectedQuantities[product.id] = selectedQty + 1;
                              }
                            });
                          },
                          onRemove: () {
                            setState(() {
                              if (selectedQty > 1) {
                                _selectedQuantities[product.id] = selectedQty - 1;
                              } else {
                                _selectedQuantities.remove(product.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),

            // ─── Continue Button at Bottom ────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B), // Dark Slate
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: totalItemsSelected > 0
                        ? () {
                            final List<ProductItemMock> selectedProducts = [];
                            _selectedQuantities.forEach((id, qty) {
                              if (qty > 0) {
                                final product = _products.firstWhere((p) => p.id == id);
                                selectedProducts.add(product);
                              }
                            });
                            context.push(
                              AppRoutes.newSale,
                              extra: {
                                'products': selectedProducts,
                                'quantities': _selectedQuantities,
                              },
                            );
                          }
                        : null,
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
