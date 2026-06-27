import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class SupplierMetricsRow extends StatelessWidget {
  final SupplierMock supplier;

  const SupplierMetricsRow({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // SUPPLY VALUE Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5), // emerald-50
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUPPLY\nVALUE',
                      style: TextStyle(
                        color: const Color(0xFF475569), // slate-600
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: const Color(0xFF059669),
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '₦${supplier.supplyValue}',
                  style: TextStyle(
                    color: const Color(0xFF059669),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // DEBTS Card
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // red-50
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFFEE2E2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DEBTS\n',
                      style: TextStyle(
                        color: const Color(0xFF475569), // slate-600
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                    Icon(
                      Icons.payment_rounded,
                      color: const Color(0xFFDC2626),
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '₦${supplier.debtAmount}',
                  style: TextStyle(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
