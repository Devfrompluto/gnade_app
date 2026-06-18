import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductItemMock {
  final String id;
  final String name;
  final String category;
  final String initials;
  final Color initialsColor;
  final int quantityInStock;

  ProductItemMock({
    required this.id,
    required this.name,
    required this.category,
    required this.initials,
    required this.initialsColor,
    required this.quantityInStock,
  });
}

class ProductItemTile extends StatelessWidget {
  final ProductItemMock product;
  final int selectedQty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const ProductItemTile({
    super.key,
    required this.product,
    required this.selectedQty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = product.quantityInStock == 0;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Initials circle
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: product.initialsColor,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                product.initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                if (isFinished)
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Item finished',
                        style: TextStyle(
                          color: const Color(0xFFEF4444),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: const Color(0xFF059669),
                          size: 10.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${product.quantityInStock.toDouble()} in stock',
                          style: TextStyle(
                            color: const Color(0xFF059669),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Action Button / Quantity Controls
          Row(
            children: [
              if (selectedQty > 0) ...[
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 26.w,
                    height: 26.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove_rounded,
                        color: Color(0xFF475569),
                        size: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '$selectedQty',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              GestureDetector(
                onTap: isFinished ? null : onAdd,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: isFinished ? Colors.transparent : const Color(0xFF1E40AF),
                    shape: BoxShape.circle,
                    border: isFinished
                        ? Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: isFinished ? const Color(0xFF94A3B8) : Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
