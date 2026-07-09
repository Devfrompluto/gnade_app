import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class AuthPinKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final VoidCallback onBackspace;

  const AuthPinKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '1'),
            _buildKey(context, '2'),
            _buildKey(context, '3'),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '4'),
            _buildKey(context, '5'),
            _buildKey(context, '6'),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, '7'),
            _buildKey(context, '8'),
            _buildKey(context, '9'),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 80.w, height: 56.h),
            _buildKey(context, '0'),
            _buildBackspaceKey(context),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(BuildContext context, String value) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onKeyPress(value),
        borderRadius: BorderRadius.circular(30.r),
        child: SizedBox(
          width: 80.w,
          height: 56.h,
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBackspace,
        borderRadius: BorderRadius.circular(30.r),
        child: SizedBox(
          width: 80.w,
          height: 56.h,
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: Color(0xFF0F172A),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
