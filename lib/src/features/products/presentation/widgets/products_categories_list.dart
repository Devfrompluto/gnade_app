import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductsCategoriesList extends StatelessWidget {
  const ProductsCategoriesList({super.key});

  @override
  Widget build(BuildContext context) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill('Beverages'),
                SizedBox(width: 8.w),
                _buildCategoryPill('Snacks'),
                SizedBox(width: 8.w),
                _buildCategoryPill('Toiletries'),
                SizedBox(width: 8.w),
                _buildCategoryPill('Canned Goods'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: const Color(0xFF475569),
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
