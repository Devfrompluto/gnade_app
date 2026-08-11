import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductBannerCard extends StatelessWidget {
  final Product product;
  final String unit;

  const ProductBannerCard({
    super.key,
    required this.product,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: product.initialsColor,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                product.initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: product.isLowStock
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '${product.quantity.toStringAsFixed(0)} $unit available',
                        style: TextStyle(
                          color: product.isLowStock
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
