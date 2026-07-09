import 'dart:async';
import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/domain/entities/user.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_profile.dart';

import 'package:gnade_app/src/features/auth/data/repositories/auth_repository_impl.dart';

/// Provides the AuthRepository instance (single source of truth)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provides a stream of auth state changes
final authStateStreamProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChanged;
});

/// Provides the current session state
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return SessionNotifier(repository: repo);
});

/// Session states
enum SessionStatus {
  unknown,
  authenticated,
  unauthenticated,
  /// Auth session exists but no users row (orphaned auth user).
  /// The user needs to complete their profile / business setup.
  incomplete,
}

class SessionState {
  final SessionStatus status;
  final AppUser? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  SessionState copyWith({SessionStatus? status, AppUser? user}) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSub;

  SessionNotifier({required AuthRepository repository})
      : _repository = repository,
        super(const SessionState()) {
    _init();
  }

  Future<void> refresh() async {
    await _init();
  }

  Future<void> _init() async {
    // Check persisted session first
    final result = await _repository.checkAuthState();
    result.fold(
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
      (user) {
        if (user == null) {
          state = const SessionState(status: SessionStatus.unauthenticated);
        } else if (user.businessId == null || user.businessId!.isEmpty) {
          // Logged in but has no active business selected yet
          state = SessionState(status: SessionStatus.incomplete, user: user);
        } else {
          state = SessionState(status: SessionStatus.authenticated, user: user);
        }
      },
    );

    // Listen for future changes
    _authSub = _repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        if (user.businessId == null || user.businessId!.isEmpty) {
          state = SessionState(status: SessionStatus.incomplete, user: user);
        } else {
          state = SessionState(status: SessionStatus.authenticated, user: user);
        }
      } else {
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final businessProfileProvider = FutureProvider<BusinessProfile?>((ref) async {
  final sessionState = ref.watch(sessionProvider);
  final businessId = sessionState.user?.businessId;

  if (businessId == null || businessId.isEmpty) {
    return null;
  }

  final repo = ref.read(authRepositoryProvider);
  final result = await repo.getBusinessProfile(businessId);

  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});
