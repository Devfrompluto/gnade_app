import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../widgets/product_item_tile.dart';
import '../../../products/presentation/providers/products_providers.dart';

class SelectItemScreen extends ConsumerStatefulWidget {
  const SelectItemScreen({super.key});

  @override
  ConsumerState<SelectItemScreen> createState() => _SelectItemScreenState();
}

class _SelectItemScreenState extends ConsumerState<SelectItemScreen> {
  String _searchQuery = '';
  int _selectedCategoryIndex = 0; // 0: All, 1: Cans, 2: Bottles, 3: PET
  String _selectedPriceMode = 'wholesale'; // 'wholesale' | 'retail'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await requireConnectivity()) return;
      ref.read(productsListProvider.notifier).loadProducts();
    });
  }

  // Track selected quantities for each product
  final Map<String, int> _selectedQuantities = {};

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Load products list from database provider
    final products = ref.watch(productsListProvider);

    // Filter products by search query and category
    final categories = ['All', 'Cans', 'Bottles', 'PET'];
    final selectedCategory = categories[_selectedCategoryIndex];

    final filteredProducts = products.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase().trim());
      final matchesCategory = selectedCategory == 'All' ||
          p.category.toLowerCase() == selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    final int totalItemsSelected =
        _selectedQuantities.values.fold(0, (sum, qty) => sum + qty);

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
                padding: EdgeInsets.fromLTRB(AppSpacing.pagePadding.w, 12.h, AppSpacing.pagePadding.w, 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          // borderRadius: BorderRadius.circular(8.r),
                          // border: Border.all(
                          //   color: const Color(0xFFCBD5E1),
                          //   width: 1,
                          // ),
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
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Pricing Mode Selector Bar ──────────────────────────────────
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.sell_outlined,
                                color: const Color(0xFF64748B), size: 16.sp),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                'Pricing Mode',
                                style: TextStyle(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildModePill('wholesale', 'Wholesale'),
                          SizedBox(width: 4.w),
                          _buildModePill('retail', 'Retail'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // ─── Category Filter Pills ───────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1E40AF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF334155),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 14.h),

              // ─── Products List Grid ──────────────────────────────────────────
              Expanded(
                child: filteredProducts.isEmpty
                    ? const Center(
                        child: AppEmptyState(
                          title: 'No items found',
                          subtitle:
                              'Create products in the inventory tab to record sales.',
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.pagePadding.w),
                        itemCount: filteredProducts.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          final currentQty =
                              _selectedQuantities[product.id] ?? 0;

                          return ProductItemTile(
                            product: product,
                            selectedQty: currentQty,
                            priceType: _selectedPriceMode,
                            onAdd: () {
                              if (currentQty < product.quantity) {
                                setState(() {
                                  _selectedQuantities[product.id] =
                                      currentQty + 1;
                                });
                              } else {
                                showGlobalToast(
                                  message:
                                      'Cannot exceed available stock (${product.quantity.toInt()})',
                                  status: 'warning',
                                );
                              }
                            },
                            onRemove: () {
                              if (currentQty > 0) {
                                setState(() {
                                  _selectedQuantities[product.id] =
                                      currentQty - 1;
                                });
                              }
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
                              final List<Product> selectedProducts = [];
                              _selectedQuantities.forEach((id, qty) {
                                if (qty > 0) {
                                  final product =
                                      products.firstWhere((p) => p.id == id);
                                  selectedProducts.add(product);
                                }
                              });
                              context.push(
                                AppRoutes.newSale,
                                extra: {
                                  'products': selectedProducts,
                                  'quantities': _selectedQuantities,
                                  'priceType': _selectedPriceMode,
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

  Widget _buildModePill(String type, String label) {
    final isSelected = _selectedPriceMode == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriceMode = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (type == 'retail'
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFFEFF6FF))
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (type == 'retail'
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF3B82F6))
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (type == 'retail'
                    ? const Color(0xFF92400E)
                    : const Color(0xFF1E40AF))
                : const Color(0xFF94A3B8),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.5.sp,
          ),
        ),
      ),
    );
  }
}
