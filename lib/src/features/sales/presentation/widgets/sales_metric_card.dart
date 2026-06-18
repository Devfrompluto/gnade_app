import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SalesMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bg;
  final Color border;
  final Color textColor;
  final bool showToggle;
  final bool isToggled;
  final VoidCallback? onToggle;

  const SalesMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.bg,
    required this.border,
    required this.textColor,
    required this.showToggle,
    this.isToggled = true,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showToggle)
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    isToggled ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: textColor.withValues(alpha: 0.6),
                    size: 13.sp,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (showToggle && !isToggled)
                Row(
                  children: List.generate(
                    3,
                    (i) => Icon(
                      Icons.star_rounded,
                      color: textColor,
                      size: 15.sp,
                    ),
                  ),
                )
              else
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
