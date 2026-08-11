import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final bool isCustomerSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.isCustomerSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final methods = ['Cash', 'Mobile', 'Bank', 'Credit'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 3.2,
      ),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        final isSelected = selectedMethod == method;
        final isDisabled = !isCustomerSelected && method == 'Credit';

        return GestureDetector(
          onTap: () => onMethodChanged(method),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0A4FCD) : Colors.white, // Custom blue for active method
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDisabled) ...[
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 12.sp,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      method,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDisabled ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
