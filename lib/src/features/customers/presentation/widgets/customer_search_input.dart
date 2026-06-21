import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class CustomerSearchInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const CustomerSearchInput({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: 'Search name or phone...',
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 13.sp,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF94A3B8),
            size: 18.sp,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }
}
