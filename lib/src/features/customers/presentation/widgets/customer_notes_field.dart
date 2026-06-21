import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class CustomerNotesField extends StatelessWidget {
  final TextEditingController controller;

  const CustomerNotesField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
            'Notes (Optional)',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            maxLines: 4,
            maxLength: 250,
            buildCounter: (context,
                {required currentLength,
                required isFocused,
                maxLength}) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Max $maxLength characters',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
            style: TextStyle(
              fontSize: 12.5.sp,
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Add specific preferences, debt history, or other details...',
              hintStyle: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 12.sp,
              ),
              contentPadding: EdgeInsets.all(12.w),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
                borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
