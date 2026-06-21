import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class PaymentStatusSelector extends StatelessWidget {
  final String selectedStatus;
  final ValueChanged<String> onStatusChanged;

  const PaymentStatusSelector({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = ['Paid', 'Unpaid', 'Partial'];

    return Row(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isSelected = selectedStatus == status;

        Color getActiveColor() {
          if (status == 'Paid') return const Color(0xFF0F9F68); // Soft green
          if (status == 'Partial') return const Color(0xFF0A4FCD); // Blue
          return const Color(0xFFE02424); // Red/Orange for Unpaid (if selected)
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => onStatusChanged(status),
            child: Container(
              margin: EdgeInsets.only(
                right: index < statuses.length - 1 ? 8.w : 0,
              ),
              height: 38.h,
              decoration: BoxDecoration(
                color: isSelected ? getActiveColor() : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
