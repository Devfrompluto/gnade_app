import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class ProductsAddSupplierCard extends StatelessWidget {
  final SupplierMock? selectedSupplier;
  final VoidCallback onSupplierTap;

  const ProductsAddSupplierCard({
    super.key,
    required this.selectedSupplier,
    required this.onSupplierTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Supplier'),
          GestureDetector(
            onTap: onSupplierTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedSupplier?.name ?? 'Select or add supplier',
                    style: TextStyle(
                      color: selectedSupplier != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      fontWeight: selectedSupplier != null ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
