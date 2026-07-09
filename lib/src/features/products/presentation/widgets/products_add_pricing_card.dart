import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductsAddPricingCard extends StatelessWidget {
  final TextEditingController costPriceController;
  final TextEditingController sellPriceController;
  final double profitMargin;

  const ProductsAddPricingCard({
    super.key,
    required this.costPriceController,
    required this.sellPriceController,
    required this.profitMargin,
  });

  @override
  Widget build(BuildContext context) {
    // Color code profit margin badge dynamically
    Color marginBg = const Color(0xFFFEF3C7); // Default amber
    Color marginText = const Color(0xFF92400E);
    if (profitMargin > 30.0) {
      marginBg = const Color(0xFFD1FAE5); // Premium emerald
      marginText = const Color(0xFF065F46);
    } else if (profitMargin < 10.0) {
      marginBg = const Color(0xFFFEE2E2); // Soft red alert
      marginText = const Color(0xFF991B1B);
    }

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Cost Price'),
                    _buildTextField(
                      controller: costPriceController,
                      hint: '1200',
                      prefixText: '₦ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid numeric';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Selling Price'),
                    _buildTextField(
                      controller: sellPriceController,
                      hint: '1656',
                      prefixText: '₦ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid numeric';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Profit margin badge row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: const Color(0xFF64748B), size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'Est. Profit Margin',
                      style: TextStyle(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: marginBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${profitMargin.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: marginText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
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
    String? prefixText,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
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
