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
    
    final result = await _authService.login(email: email, password: password);
    
    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }

      final user = AppUser(
        id: userData['id'], 
        email: userData['email'] ?? email, 
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
      
      return right(user);
    });
  }

  @override
  FutureEither<AppUser> signUp({
    required String name, 
    required String email, 
    required String password,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final user = AppUser(id: 'mock-user-123', email: email, name: name);
      _currentMockUser = user;
      _mockUserStreamController.add(_currentMockUser);
      return right(user);
    }
    
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );

    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Sign up failed: User record corrupted'));
      }

      final user = AppUser(
        id: userData['id'], 
        email: userData['email'] ?? email, 
        name: name,
      );
      
      return right(user);
    });
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
    
    return result.map((userData) {
      if (userData == null) return null;

      return AppUser(
        id: userData['id'], 
        email: userData['email'] ?? '', 
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
    });
  }
}
