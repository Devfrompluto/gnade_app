import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductsCategoriesList extends ConsumerWidget {
  const ProductsCategoriesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 12.h),
          categoriesAsync.when(
            data: (categories) {
              final allCategories = ['All', ...categories];

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: allCategories.map((name) {
                    final isSelected = (name == 'All' && selectedCategory == null) ||
                        (selectedCategory != null && selectedCategory.toLowerCase() == name.toLowerCase());

                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _buildCategoryPill(
                        context: context,
                        ref: ref,
                        name: name,
                        isSelected: isSelected,
                        onTap: () {
                          if (name == 'All') {
                            ref.read(selectedCategoryFilterProvider.notifier).state = null;
                          } else {
                            ref.read(selectedCategoryFilterProvider.notifier).state =
                                isSelected ? null : name;
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => Skeletonizer(
              enabled: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(4, (index) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildCategoryPill(
                      context: context,
                      ref: ref,
                      name: 'Category $index',
                      isSelected: false,
                      onTap: () {},
                    ),
                  )),
                ),
              ),
            ),
            error: (err, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required BuildContext context,
    required WidgetRef ref,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9), // active blue vs slate-100
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF475569), // white vs slate-600
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }
}
