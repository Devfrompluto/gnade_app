import 'dart:async';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/auth/domain/entities/user.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;
  final _mockUserStreamController = StreamController<AppUser?>.broadcast();
  AppUser? _currentMockUser;

  static const _mockUser = AppUser(
    id: 'mock-user-123',
    email: 'owner@gnade.com',
    name: 'Gnade Owner',
    businessId: 'mock-business-456',
    role: 'owner',
  );

  @override
  Stream<AppUser?> get onAuthStateChanged {
    if (AppConfig.useMockData) {
      return _mockUserStreamController.stream;
    }
    return _authService.authStateChanges.map((userData) {
      if (userData == null) return null;
      return AppUser(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _currentMockUser = _mockUser;
      _mockUserStreamController.add(_currentMockUser);
      return right(_mockUser);
    }

    // 1. Authenticate with Supabase Auth
    final result = await _authService.login(email: email, password: password);

    return result.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) {
          return left(const ServerFailure('Login failed: User record not found'));
        }

        // 2. Fetch user profile (business_id, role) from users table
        final profileResult = await _authService.getUserProfile();

        return profileResult.fold(
          (failure) => left(failure),
          (profile) {
            if (profile == null) {
              // Orphaned auth user — no users row exists.
              // Return a partial AppUser so session_provider can detect this.
              return right(AppUser(
                id: userData['id'],
                email: userData['email'] ?? email,
                name: userData['name'],
                photoUrl: userData['photoUrl'],
              ));
            }

            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? email,
              name: profile['full_name'] ?? userData['name'],
              photoUrl: userData['photoUrl'],
              businessId: profile['business_id'],
              role: profile['role'],
            ));
          },
        );
      },
    );
  }

  @override
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String businessName,
    required String businessCategory,
    required String phoneNumber,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final user = AppUser(
        id: 'mock-user-123',
        email: email,
        name: name,
        businessId: 'mock-business-456',
        role: 'owner',
      );
      _currentMockUser = user;
      _mockUserStreamController.add(_currentMockUser);
      return right(user);
    }

    // 1. Register with Supabase Auth
    final authResult = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );

    return authResult.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) {
          return left(const ServerFailure('Sign up failed: User record not created'));
        }

        // 2. Call initialize_business RPC to atomically create business + user rows
        final initResult = await _authService.initializeBusiness(
          businessName: businessName,
          businessCategory: businessCategory,
          userName: name,
          userPhone: phoneNumber,
        );

        return initResult.fold(
          (failure) {
            // Auth user was created but business init failed.
            // Return partial user — session_provider will detect orphan state.
            AppLogger.error(
              'Business initialization failed after sign up: ${failure.message}',
            );
            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? email,
              name: name,
            ));
          },
          (initData) {
            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? email,
              name: name,
              businessId: initData['business_id'],
              role: initData['role'],
            ));
          },
        );
      },
    );
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    if (AppConfig.useMockData) {
      return Future.value(right(null));
    }
    return _authService.forgotPassword(email: email);
  }

  @override
  FutureEither<void> logout() async {
    if (AppConfig.useMockData) {
      _currentMockUser = null;
      _mockUserStreamController.add(null);
      return right(null);
    }
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    if (AppConfig.useMockData) {
      return right(_currentMockUser);
    }

    final result = await _authService.getCurrentUser();

    return result.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) return right(null);

        // Fetch user profile to get business_id and role
        final profileResult = await _authService.getUserProfile();

        return profileResult.fold(
          (failure) {
            // Return partial user — profile fetch failed but auth session exists
            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? '',
              name: userData['name'],
              photoUrl: userData['photoUrl'],
            ));
          },
          (profile) {
            if (profile == null) {
              // Orphaned auth user — session exists but no users row
              return right(AppUser(
                id: userData['id'],
                email: userData['email'] ?? '',
                name: userData['name'],
                photoUrl: userData['photoUrl'],
              ));
            }

            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? '',
              name: profile['full_name'] ?? userData['name'],
              photoUrl: userData['photoUrl'],
              businessId: profile['business_id'],
              role: profile['role'],
            ));
          },
        );
      },
    );
  }
}
