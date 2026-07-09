import 'dart:async';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gnade_app/src/features/auth/domain/entities/user.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_profile.dart';

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
    return _authService.authStateChanges.asyncMap((userData) async {
      if (userData == null) return null;

      final profileResult = await _authService.getUserProfile();
      return profileResult.fold(
        (_) => AppUser(
          id: userData['id'] ?? '',
          email: userData['email'] ?? '',
          name: userData['name'],
          photoUrl: userData['photoUrl'],
        ),
        (profile) async {
          if (profile == null) {
            // Try automatic background initialization using metadata stored on signup
            final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
            final bName = userMetadata?['business_name'] as String?;
            final bCat = userMetadata?['business_category'] as String?;
            final uPhone = userMetadata?['phone_number'] as String?;
            final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

            if (bName != null) {
              AppLogger.info('Orphan profile detected in stream. Initializing business...');
              final initResult = await _authService.initializeBusiness(
                businessName: bName,
                businessCategory: bCat,
                userName: uName,
                userPhone: uPhone,
              );
              return initResult.fold(
                (_) => AppUser(
                  id: userData['id'] ?? '',
                  email: userData['email'] ?? '',
                  name: userData['name'],
                  photoUrl: userData['photoUrl'],
                ),
                (initData) => AppUser(
                  id: userData['id'] ?? '',
                  email: userData['email'] ?? '',
                  name: uName,
                  photoUrl: userData['photoUrl'],
                  businessId: initData['business_id'],
                  role: initData['role'],
                ),
              );
            }

            return AppUser(
              id: userData['id'] ?? '',
              email: userData['email'] ?? '',
              name: userData['name'],
              photoUrl: userData['photoUrl'],
            );
          }

          return AppUser(
            id: userData['id'] ?? '',
            email: userData['email'] ?? '',
            name: profile['full_name'] ?? userData['name'],
            photoUrl: userData['photoUrl'],
            businessId: profile['business_id'],
            role: profile['role'],
          );
        },
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
          (profile) async {
            if (profile == null) {
              // Try automatic background initialization using metadata stored on signup
              final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
              final bName = userMetadata?['business_name'] as String?;
              final bCat = userMetadata?['business_category'] as String?;
              final uPhone = userMetadata?['phone_number'] as String?;
              final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

              if (bName != null) {
                AppLogger.info('Orphan profile detected on login. Initializing business...');
                final initResult = await _authService.initializeBusiness(
                  businessName: bName,
                  businessCategory: bCat,
                  userName: uName,
                  userPhone: uPhone,
                );

                return initResult.fold(
                  (initFailure) {
                    AppLogger.error('Auto business initialization failed: ${initFailure.message}');
                    return right(AppUser(
                      id: userData['id'],
                      email: userData['email'] ?? email,
                      name: uName,
                      photoUrl: userData['photoUrl'],
                    ));
                  },
                  (initData) {
                    AppLogger.success('Auto business initialization succeeded!');
                    final completedUser = AppUser(
                      id: userData['id'],
                      email: userData['email'] ?? email,
                      name: uName,
                      photoUrl: userData['photoUrl'],
                      businessId: initData['business_id'],
                      role: initData['role'],
                    );
                    return right(completedUser);
                  },
                );
              }

              // Return partial user if no business metadata found
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
    // Pass business details in metadata so we can recover them post-verification
    final authResult = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      metadata: {
        'business_name': businessName,
        'business_category': businessCategory,
        'phone_number': phoneNumber,
      },
    );

    return authResult.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) {
          return left(const ServerFailure('Sign up failed: User record not created'));
        }

        // Check if email verification is required (session is null)
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return left(const EmailVerificationRequiredFailure(
            'A verification email has been sent. Please confirm your email address and log in.',
          ));
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
          (profile) async {
            if (profile == null) {
              // Try automatic background initialization using metadata stored on signup
              final userMetadata = Supabase.instance.client.auth.currentUser?.userMetadata;
              final bName = userMetadata?['business_name'] as String?;
              final bCat = userMetadata?['business_category'] as String?;
              final uPhone = userMetadata?['phone_number'] as String?;
              final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

              if (bName != null) {
                AppLogger.info('Orphan profile detected on session restore. Initializing business...');
                final initResult = await _authService.initializeBusiness(
                  businessName: bName,
                  businessCategory: bCat,
                  userName: uName,
                  userPhone: uPhone,
                );
                return initResult.fold(
                  (_) => right(AppUser(
                    id: userData['id'],
                    email: userData['email'] ?? '',
                    name: uName,
                    photoUrl: userData['photoUrl'],
                  )),
                  (initData) => right(AppUser(
                    id: userData['id'],
                    email: userData['email'] ?? '',
                    name: uName,
                    photoUrl: userData['photoUrl'],
                    businessId: initData['business_id'],
                    role: initData['role'],
                  )),
                );
              }

              // Return partial user if no business metadata found
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

  @override
  FutureEither<BusinessProfile> getBusinessProfile(String businessId) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return right(BusinessProfile(
        id: businessId,
        name: 'Gnade Multiconcept Mock',
        category: 'Retail / FMCG',
        phone: '+234 801 234 5678',
        address: '15 Trade Route Rd, Lagos',
        currency: 'NGN',
      ));
    }

    final result = await _authService.getBusinessProfile(businessId);
    return result.fold(
      (failure) => left(failure),
      (data) {
        if (data == null) {
          return left(const ServerFailure('Business profile not found'));
        }
        return right(BusinessProfile.fromMap(data));
      },
    );
  }
}
