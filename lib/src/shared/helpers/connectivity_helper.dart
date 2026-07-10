import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:gnade_app/src/services/internet_connection_service.dart';

/// Emits `true` when the device has internet, `false` when it doesn't.
/// Widgets can `ref.watch(connectivityProvider)` to react to changes.
final connectivityProvider = StreamProvider<bool>((ref) {
  return InternetConnectionService.instance.connectionStream.map(
    (status) => status == InternetStatus.connected,
  );
});

/// One-shot connectivity gate for user-initiated actions.
///
/// Returns `true` if the device is online. If offline, shows a debounced
/// warning toast and returns `false` so the caller can bail out early.
///
/// Usage:
/// ```dart
/// onPressed: () async {
///   if (!await requireConnectivity()) return;
///   // proceed with sale, edit, etc.
/// }
/// ```
Future<bool> requireConnectivity() async {
  final online = await InternetConnectionService.instance.hasConnection();
  if (!online) {
    InternetConnectionService.instance.showNoConnectionToast();
  }
  return online;
}
