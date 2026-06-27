import 'package:gnade_app/src/imports/imports.dart';

class SettingsGroupCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 8.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: const Color(0xFF64748B), // Slate grey
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(children.length * 2 - 1, (index) {
              if (index.isOdd) {
                return const Divider(height: 1, color: Color(0xFFF1F5F9));
              }
              return children[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }
}
