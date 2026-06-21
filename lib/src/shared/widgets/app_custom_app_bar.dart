import '../../imports/imports.dart';

class AppCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final Color backgroundColor;
  final bool showBottomBorder;
  final Color bottomBorderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;

  const AppCustomAppBar({
    super.key,
    required this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBackPressed,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.showBottomBorder = true,
    this.bottomBorderColor = const Color(0xFFE2E8F0),
    this.fontSize,
    this.fontWeight,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading ?? IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: textColor ?? colorScheme.onSurface,
          size: 20.sp,
        ),
        onPressed: onBackPressed ?? () => context.pop(),
      ),
      title: titleWidget ?? Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: fontWeight ?? FontWeight.bold,
          color: textColor ?? colorScheme.onSurface,
          fontSize: fontSize ?? 16.sp,
        ),
      ),
      bottom: showBottomBorder
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: bottomBorderColor,
                height: 1,
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showBottomBorder ? 1 : 0));
}
