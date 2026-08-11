import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/supplier.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final Color avatarBg;
  final VoidCallback onTap;

  const SupplierCard({
    super.key,
    required this.supplier,
    required this.avatarBg,
    required this.onTap,
  });

  String _formatFullCurrency(double amount) {
    return '₦ ${NumberFormat('#,##0').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            // Avatar Icon Circle
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  supplier.initial,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name and Phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    supplier.phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Right Debt Tag or Chevron
            if (supplier.hasDebt)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Debt',
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _formatFullCurrency(supplier.debtAmount),
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFCBD5E1),
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
