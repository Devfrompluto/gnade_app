import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class AppMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isGreen;
  final bool showValue;
  final VoidCallback onToggleVisibility;
  final bool isIncreasing;

  const AppMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.isGreen,
    required this.showValue,
    required this.onToggleVisibility,
    this.isIncreasing = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = theme.textTheme;

    // Define colors to match the premium design screenshot
    final Color borderColor = isGreen 
        ? const Color(0xFFCBEAD7) 
        : const Color(0xFFF7D2D2);
    final Color backgroundColor = isGreen 
        ? const Color(0xFFE8F6EE) 
        : const Color(0xFFFBECEB);
    final Color textColor = isGreen 
        ? const Color(0xFF0F8546) 
        : const Color(0xFFD32F2F);
    
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row (Label + Trend Icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(
                  isIncreasing 
                      ? Icons.trending_up_rounded 
                      : Icons.trending_down_rounded,
                  color: textColor,
                  size: 14.sp,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            
            // Value Row (Stars or Text + Toggle Button)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: showValue
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      : Row(
                          children: List.generate(
                            4,
                            (index) => Padding(
                              padding: EdgeInsets.only(right: 3.w),
                              child: Icon(
                                Icons.star_rounded,
                                color: textColor,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: onToggleVisibility,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    child: Icon(
                      showValue 
                          ? Icons.visibility_outlined 
                          : Icons.visibility_off_outlined,
                      color: textColor.withValues(alpha: 0.6),
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
