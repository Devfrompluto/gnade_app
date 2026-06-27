import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductsFilterPills extends ConsumerWidget {
  const ProductsFilterPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(productsFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildPill(
            ref,
            'All',
            isActive: activeFilter == ProductFilterType.all,
            type: ProductFilterType.all,
          ),
          SizedBox(width: 8.w),
          _buildPill(
            ref,
            'Expired',
            isActive: activeFilter == ProductFilterType.expired,
            type: ProductFilterType.expired,
          ),
          SizedBox(width: 8.w),
          _buildPill(
            ref,
            'Low Stock',
            isActive: activeFilter == ProductFilterType.lowStock,
            type: ProductFilterType.lowStock,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(
    WidgetRef ref,
    String text, {
    required bool isActive,
    required ProductFilterType type,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(productsFilterProvider.notifier).state = type;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.transparent, // Blue if active
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}
