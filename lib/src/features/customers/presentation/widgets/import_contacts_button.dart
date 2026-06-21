import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ImportContactsButton extends StatelessWidget {
  final VoidCallback onTap;

  const ImportContactsButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // soft blue background
          border: Border.all(
            color: const Color(0xFFDBEAFE),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone_outlined,
              color: const Color(0xFF1E40AF),
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Import from Contacts',
              style: TextStyle(
                color: const Color(0xFF1E40AF),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
