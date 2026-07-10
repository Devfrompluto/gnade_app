import 'dart:async';
import '../imports/imports.dart';

/// Singleton service for monitoring internet connectivity.
///
/// Exposes:
/// - [hasConnection] — one-shot check (for guards before actions)
/// - [connectionStream] — real-time stream (for Riverpod providers)
/// - [showNoConnectionToast] — debounced toast (prevents flood)
class InternetConnectionService {
  InternetConnectionService._();
  static final InternetConnectionService _instance = InternetConnectionService._();
  static InternetConnectionService get instance => _instance;

  /// Re-use a single checker instance so we don't open duplicate sockets.
  final InternetConnection _checker = InternetConnection();

  /// Cooldown tracking for the "no internet" toast.
  DateTime? _lastToastShown;
  static const _toastCooldown = Duration(seconds: 5);

  /// One-shot connectivity check.
  Future<bool> hasConnection() async {
    try {
      return await _checker.hasInternetAccess;
    } catch (_) {
      return false;
    }
  }

  /// Real-time stream of connectivity status.
  Stream<InternetStatus> get connectionStream =>
      _checker.onStatusChange;

  /// Shows a "no internet" warning toast, but only once per [_toastCooldown]
  /// window to prevent toast flooding when multiple providers fire at once.
  void showNoConnectionToast() {
    final now = DateTime.now();
    if (_lastToastShown != null &&
        now.difference(_lastToastShown!) < _toastCooldown) {
      return; // Suppress — a toast was shown recently
    }
    _lastToastShown = now;
    showGlobalToast(
      message: 'No internet connection. Please check your connection and try again.',
      status: 'warning',
    );
  }
}
