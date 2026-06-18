import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';


class SessionListenerWrapper extends ConsumerWidget {
  final Widget child;
  const SessionListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<SessionState>(sessionProvider, (prev, next) {
      if (next.status != SessionStatus.unknown) {
        FlutterNativeSplash.remove();
        final navContext = rootContext;
        if (navContext != null && navContext.mounted) {
          if (next.status == SessionStatus.authenticated) {
            navContext.go(AppRoutes.dashboard);
          } else if (next.status == SessionStatus.unauthenticated) {
            navContext.go(AppRoutes.onboarding);
          }
        }
      }
    });

    return child;
  }
}
