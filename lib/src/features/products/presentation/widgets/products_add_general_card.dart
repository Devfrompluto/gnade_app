import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductsAddGeneralCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController skuController;
  final String? selectedCategory;
  final String selectedUnit;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onGenerateSku;
  final VoidCallback onCategoryTap;

  const ProductsAddGeneralCard({
    super.key,
    required this.nameController,
    required this.skuController,
    required this.selectedCategory,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onGenerateSku,
    required this.onCategoryTap,
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
          _buildLabel('Product Name'),
          _buildTextField(
            controller: nameController,
            hint: 'Premium Vita Milk 500g',
            validator: (val) => val == null || val.isEmpty ? 'Product name is required' : null,
          ),
          SizedBox(height: 16.h),
          _buildLabel('SKU / Barcode'),
          _buildTextField(
            controller: skuController,
            hint: 'SKU-8932019',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Color(0xFF2563EB)),
              onPressed: onGenerateSku,
              tooltip: 'Generate SKU',
            ),
          ),
          SizedBox(height: 16.h),
          _buildLabel('Category'),
          GestureDetector(
            onTap: onCategoryTap,
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
                    selectedCategory ?? 'Select Category',
                    style: TextStyle(
                      color: selectedCategory != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                      fontWeight: selectedCategory != null ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13.sp,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 20.sp),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildLabel('Unit Type'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['pcs', 'carton', 'bottle', 'crate', 'litre', 'kg'].map((unit) {
                final isSelected = selectedUnit == unit;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(unit),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) onUnitChanged(unit);
                    },
                    selectedColor: const Color(0xFFEFF6FF),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        color: const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
        fontSize: 13.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF94A3B8),
          fontSize: 13.sp,
          fontWeight: FontWeight.normal,
        ),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}
