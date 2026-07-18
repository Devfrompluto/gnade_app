import '../../imports/imports.dart';

void showToast(
  BuildContext context, {
  required String message,
  String? status = 'success',
  dynamic icon,
  Duration? duration,
  bool? autoDismiss,
}) {
  var activeContext = context;
  if (!context.mounted) {
    final rc = rootContext;
    if (rc != null && rc.mounted) {
      activeContext = rc;
    } else {
      AppLogger.warning('Cannot show toast: no active mounted context available.');
      return;
    }
  }

  ColorScheme colorScheme;
  AppColorsExtension appColors;
  ThemeData theme;

  try {
    colorScheme = activeContext.colors;
    appColors = activeContext.appColors;
    theme = activeContext.theme;
  } catch (e) {
    final rc = rootContext;
    if (rc != null && rc.mounted) {
      activeContext = rc;
      try {
        colorScheme = activeContext.colors;
        appColors = activeContext.appColors;
        theme = activeContext.theme;
      } catch (_) {
        AppLogger.warning('Cannot show toast: failed to look up theme on rootContext.');
        return;
      }
    } else {
      AppLogger.warning('Cannot show toast: context is deactivated and no rootContext is available.');
      return;
    }
  }

  final toastStatus = status ?? 'info';

  final (backgroundColor, foregroundColor, iconColor) = switch (toastStatus) {
    'error' => (
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
        colorScheme.error,
      ),
    'success' => (
        appColors.successContainer ?? appColors.success,
        appColors.onSuccessContainer ?? appColors.onSuccess,
        appColors.success,
      ),
    'warning' => (
        appColors.warningContainer ?? appColors.warning,
        appColors.onWarningContainer ?? appColors.onWarning,
        appColors.warning,
      ),
    'info' => (
        appColors.infoContainer ?? appColors.info,
        appColors.onInfoContainer ?? appColors.onInfo,
        appColors.info,
      ),
    _ => (
        theme.scaffoldBackgroundColor,
        colorScheme.onSurface,
        colorScheme.onSurfaceVariant,
      ),
  };

  return ToastBar(
    position: ToastPosition.top,
    autoDismiss: autoDismiss ?? true,
    toastDuration: duration ?? const Duration(seconds: 2),
    animationDuration: const Duration(milliseconds: 150),
    animationCurve: Curves.easeIn,
    builder: (ctx) => ToastCard(
      color: backgroundColor,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
      leading: AppIcon(
        icon: icon ??
            (toastStatus == 'success'
                ? HugeIcons.strokeRoundedCheckmarkCircle01
                : toastStatus == 'error'
                    ? HugeIcons.strokeRoundedAlertCircle
                    : HugeIcons.strokeRoundedInformationCircle),
        color: iconColor,
        size: 22.sp,
      ),
      title: Text(
        message,
        style: ctx.theme.textTheme.labelSmall!.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11.sp,
          color: foregroundColor,
        ),
      ),
    ),
  ).show(activeContext);
}

void showGlobalToast({
  required String message,
  String? status = 'success',
  dynamic icon,
  Duration? duration,
  bool? autoDismiss,
}) {
  final ctx = rootContext;
  if (ctx == null) return;

  showToast(
    ctx,
    message: message,
    status: status,
    icon: icon,
    duration: duration,
    autoDismiss: autoDismiss,
  );
}
