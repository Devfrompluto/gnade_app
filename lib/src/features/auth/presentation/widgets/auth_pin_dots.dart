import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class AuthPinDots extends StatelessWidget {
  final int pinLength;

  const AuthPinDots({
    super.key,
    required this.pinLength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? const Color(0xFF1A56DB) : Colors.transparent,
            border: Border.all(
              color: isFilled ? const Color(0xFF1A56DB) : const Color(0xFFCBD5E1),
              width: 2.5.w,
            ),
          ),
        );
      }),
    );
  }
}
