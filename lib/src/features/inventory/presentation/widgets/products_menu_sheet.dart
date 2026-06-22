import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductsMenuSheet extends ConsumerWidget {
  const ProductsMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24.r),
        ),
      ),
      builder: (context) => const ProductsMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLayout = ref.watch(productsLayoutProvider);
    final currentSort = ref.watch(productsSortProvider);

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7, // Cap at 70% of screen height so it doesn't take full screen
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1), // slate-300
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Management Title
                  Text(
                    'Categories management',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Categories Actions
                  _buildCategoryButton(
                    text: 'Edit and add new category',
                    onTap: () {
                      Navigator.pop(context);
                      showGlobalToast(message: 'Category management feature coming soon');
                    },
                  ),
                  SizedBox(height: 8.h),
                  _buildCategoryButton(
                    text: 'Add products to a category',
                    onTap: () {
                      Navigator.pop(context);
                      showGlobalToast(message: 'Add products to category feature coming soon');
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Layout Type Title
                  Text(
                    'Layout type',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Layout Type Selector Container
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildRadioRow<ProductLayoutType>(
                          title: 'List view',
                          value: ProductLayoutType.list,
                          groupValue: currentLayout,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsLayoutProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductLayoutType>(
                          title: 'Grid view',
                          value: ProductLayoutType.grid,
                          groupValue: currentLayout,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsLayoutProvider.notifier).state = val;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Sort List of Products Title
                  Text(
                    'Sort list of products',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Sorting Options Container
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFEFF6FF), width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildRadioRow<ProductSortType>(
                          title: 'Newest to Oldest',
                          value: ProductSortType.newestToOldest,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductSortType>(
                          title: 'Old to new',
                          value: ProductSortType.oldToNew,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductSortType>(
                          title: 'Alphabetical (A-Z)',
                          value: ProductSortType.alphabeticalAZ,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductSortType>(
                          title: 'Alphabetical (Z-A)',
                          value: ProductSortType.alphabeticalZA,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductSortType>(
                          title: 'Quantity (High to Low)',
                          value: ProductSortType.quantityHighToLow,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFEFF6FF)),
                        _buildRadioRow<ProductSortType>(
                          title: 'Quantity (Low to High)',
                          value: ProductSortType.quantityLowToHigh,
                          groupValue: currentSort,
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(productsSortProvider.notifier).state = val;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF), // Soft light indigo background
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF3730A3), // Deep indigo text
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildRadioRow<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1E293B), // slate-800
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
            // Custom Radio display matching the premium mockup
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8), // active blue vs slate-400
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
