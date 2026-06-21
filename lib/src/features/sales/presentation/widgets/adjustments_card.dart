import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class AdjustmentsCard extends StatelessWidget {
  final TextEditingController discountController;
  final TextEditingController taxController;
  final bool hasDiscount;
  final bool hasTax;
  final VoidCallback onDiscountRemoved;
  final VoidCallback onTaxRemoved;
  final VoidCallback onDiscountAdded;
  final VoidCallback onTaxAdded;
  final VoidCallback onChanged;

  const AdjustmentsCard({
    super.key,
    required this.discountController,
    required this.taxController,
    required this.hasDiscount,
    required this.hasTax,
    required this.onDiscountRemoved,
    required this.onTaxRemoved,
    required this.onDiscountAdded,
    required this.onTaxAdded,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjustments',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // Discount Section
          if (hasDiscount) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
                GestureDetector(
                  onTap: onDiscountRemoved,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1E293B),
                ),
                onChanged: (_) => onChanged(),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                    child: Text(
                      '₦',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: onDiscountAdded,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discount',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+ Add',
                      style: TextStyle(
                        color: const Color(0xFF0A4FCD),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          SizedBox(height: 12.h),

          // Divider between sections if both options exist
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          SizedBox(height: 12.h),

          // Tax Section
          if (hasTax) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (%)',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
                GestureDetector(
                  onTap: onTaxRemoved,
                  child: Text(
                    'Remove',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              height: 38.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: taxController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1E293B),
                ),
                onChanged: (_) => onChanged(),
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                    child: Text(
                      '%',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: onTaxAdded,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (%)',
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '+ Add',
                      style: TextStyle(
                        color: const Color(0xFF0A4FCD),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
