import 'package:gnade_app/src/imports/imports.dart';

class MoreCategoryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const MoreCategoryCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Title
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 12.h),
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFF2563EB), // Blue color
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // Tiles list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFF1F5F9),
            ),
            itemBuilder: (context, index) => children[index],
          ),
        ],
      ),
    );
  }
}
