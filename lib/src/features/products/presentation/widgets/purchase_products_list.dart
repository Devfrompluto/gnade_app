import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class PurchaseProductsList extends StatelessWidget {
  final List<SupplierPurchaseItemMock> items;
  final VoidCallback? onItemDelete;

  const PurchaseProductsList({
    super.key,
    required this.items,
    this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 8.h),
            child: Text(
              'Products',
              style: TextStyle(
                color: const Color(0xFF1E293B), // slate-800
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 1),

          // Items List
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: Text(
                  'No items in this purchase.',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFF1F5F9),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Product details (Left)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: const Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '${item.qty} @ ${NumberFormat('#,###').format(item.unitPrice)}',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Subtotal and actions (Right)
                      Row(
                        children: [
                          Text(
                            item.total,
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w900,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          GestureDetector(
                            onTap: () {
                              if (onItemDelete != null) {
                                onItemDelete!();
                              } else {
                                showGlobalToast(message: 'Item delete coming soon');
                              }
                            },
                            child: Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2), // soft red
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: const Color(0xFFDC2626),
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
