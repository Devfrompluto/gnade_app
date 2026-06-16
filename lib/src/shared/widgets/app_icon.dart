import '../../imports/imports.dart';

/// A wrapper widget that handles different icon libraries.
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
  });

  /// The icon to display (either IconData or HugeIcons list format).
  final dynamic icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (icon is IconData) {
      return Icon(
        icon as IconData,
        size: size,
        color: color,
      );
    } else if (icon is List<List<dynamic>>) {
      return HugeIcon(
        icon: icon as List<List<dynamic>>,
        size: size ?? 24.0,
        color: color,
      );
    }
    return const SizedBox.shrink();
  }
}
