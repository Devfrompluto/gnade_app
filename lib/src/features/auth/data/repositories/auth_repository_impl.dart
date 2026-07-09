import 'dart:async';
import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:gnade_app/src/features/auth/domain/entities/user.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_profile.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';

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
          final currentUser = Supabase.instance.client.auth.currentUser;
          final activeBusinessId = currentUser?.appMetadata['active_business_id']?.toString();
          final activeRole = currentUser?.appMetadata['active_role']?.toString();

          if (profile == null) {
            final userMetadata = currentUser?.userMetadata;
            final uPhone = userMetadata?['phone_number'] as String?;
            final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

            try {
              await Supabase.instance.client.from('users').upsert({
                'id': userData['id'] ?? '',
                'full_name': uName,
                'phone': uPhone,
              });
            } catch (e) {
              AppLogger.error('Failed to auto-upsert profile: $e');
            }
            
            return AppUser(
              id: userData['id'] ?? '',
              email: userData['email'] ?? '',
              name: uName,
              photoUrl: userData['photoUrl'],
              businessId: activeBusinessId,
              role: activeRole,
            );
          }

          return AppUser(
            id: userData['id'] ?? '',
            email: userData['email'] ?? '',
            name: profile['full_name'] ?? userData['name'],
            photoUrl: userData['photoUrl'],
            businessId: activeBusinessId,
            role: activeRole,
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

    final result = await _authService.login(email: email, password: password);

    return result.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) {
          return left(const ServerFailure('Login failed: User record not found'));
        }

        final profileResult = await _authService.getUserProfile();

        return profileResult.fold(
          (failure) => left(failure),
          (profile) async {
            final currentUser = Supabase.instance.client.auth.currentUser;
            final activeBusinessId = currentUser?.appMetadata['active_business_id']?.toString();
            final activeRole = currentUser?.appMetadata['active_role']?.toString();

            if (profile == null) {
              final userMetadata = currentUser?.userMetadata;
              final uPhone = userMetadata?['phone_number'] as String?;
              final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

              try {
                await Supabase.instance.client.from('users').upsert({
                  'id': userData['id'],
                  'full_name': uName,
                  'phone': uPhone,
                });
              } catch (e) {
                AppLogger.error('Failed to auto-upsert profile: $e');
              }

              return right(AppUser(
                id: userData['id'],
                email: userData['email'] ?? email,
                name: uName,
                photoUrl: userData['photoUrl'],
                businessId: activeBusinessId,
                role: activeRole,
              ));
            }

            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? email,
              name: profile['full_name'] ?? userData['name'],
              photoUrl: userData['photoUrl'],
              businessId: activeBusinessId,
              role: activeRole,
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
    required String phoneNumber,
  }) async {
    if (AppConfig.useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final user = AppUser(
        id: 'mock-user-123',
        email: email,
        name: name,
      );
      _currentMockUser = user;
      _mockUserStreamController.add(_currentMockUser);
      return right(user);
    }

    final authResult = await _authService.signUp(
      name: name,
      email: email,
      password: password,
      metadata: {
        'phone_number': phoneNumber,
      },
    );

    return authResult.fold(
      (failure) => left(failure),
      (userData) async {
        if (userData == null) {
          return left(const ServerFailure('Sign up failed: User record not created'));
        }

        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return left(const EmailVerificationRequiredFailure(
            'A verification email has been sent. Please confirm your email address and log in.',
          ));
        }

        try {
          await Supabase.instance.client.from('users').upsert({
            'id': userData['id'],
            'full_name': name,
            'phone': phoneNumber,
          });
        } catch (e) {
          AppLogger.error('Failed to insert user profile: $e');
        }

        return right(AppUser(
          id: userData['id'],
          email: userData['email'] ?? email,
          name: name,
        ));
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

        final profileResult = await _authService.getUserProfile();

        return profileResult.fold(
          (failure) {
            final currentUser = Supabase.instance.client.auth.currentUser;
            final activeBusinessId = currentUser?.appMetadata['active_business_id']?.toString();
            final activeRole = currentUser?.appMetadata['active_role']?.toString();
            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? '',
              name: userData['name'],
              photoUrl: userData['photoUrl'],
              businessId: activeBusinessId,
              role: activeRole,
            ));
          },
          (profile) async {
            final currentUser = Supabase.instance.client.auth.currentUser;
            final activeBusinessId = currentUser?.appMetadata['active_business_id']?.toString();
            final activeRole = currentUser?.appMetadata['active_role']?.toString();

            if (profile == null) {
              final userMetadata = currentUser?.userMetadata;
              final uPhone = userMetadata?['phone_number'] as String?;
              final uName = userMetadata?['name'] as String? ?? userData['name'] ?? '';

              try {
                await Supabase.instance.client.from('users').upsert({
                  'id': userData['id'],
                  'full_name': uName,
                  'phone': uPhone,
                });
              } catch (e) {
                AppLogger.error('Failed to auto-upsert profile: $e');
              }

              return right(AppUser(
                id: userData['id'],
                email: userData['email'] ?? '',
                name: uName,
                photoUrl: userData['photoUrl'],
                businessId: activeBusinessId,
                role: activeRole,
              ));
            }

            return right(AppUser(
              id: userData['id'],
              email: userData['email'] ?? '',
              name: profile['full_name'] ?? userData['name'],
              photoUrl: userData['photoUrl'],
              businessId: activeBusinessId,
              role: activeRole,
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

  @override
  FutureEither<List<BusinessSummary>> getBusinesses() async {
    if (AppConfig.useMockData) {
      return right([
        const BusinessSummary(
          id: 'mock-business-456',
          name: 'Gnade Multiconcept Mock',
          category: 'Retail',
          currency: 'NGN',
          role: 'owner',
          hasPin: true,
        ),
      ]);
    }

    final result = await _authService.getBusinesses();
    return result.fold(
      (failure) => left(failure),
      (list) {
        final summaries = list.map((item) => BusinessSummary.fromMap(item as Map<String, dynamic>)).toList();
        return right(summaries);
      },
    );
  }

  @override
  FutureEither<Map<String, dynamic>> createBusiness({
    required String name,
    required String category,
    required String userName,
    required String userPhone,
    required String pin,
    String? phone,
    String? address,
    String? logoUrl,
  }) async {
    if (AppConfig.useMockData) {
      const user = AppUser(
        id: 'mock-user-123',
        email: 'owner@gnade.com',
        name: 'Gnade Owner',
        businessId: 'mock-business-456',
        role: 'owner',
      );
      _currentMockUser = user;
      _mockUserStreamController.add(_currentMockUser);
      return right({
        'business_id': 'mock-business-456',
        'role': 'owner',
      });
    }

    final result = await _authService.createBusiness(
      name: name,
      category: category,
      userName: userName,
      userPhone: userPhone,
      pin: pin,
    );

    return result.fold(
      (failure) => left(failure),
      (data) async {
        final businessId = data['business_id'] as String?;
        if (businessId != null) {
          if (phone != null || address != null || logoUrl != null) {
            try {
              await Supabase.instance.client.from('businesses').update({
                if (phone != null) 'phone': phone,
                if (address != null) 'address': address,
                if (logoUrl != null) 'logo_url': logoUrl,
              }).eq('id', businessId);
            } catch (e) {
              AppLogger.error('Failed to update business metadata: $e');
            }
          }
        }
        return right(data);
      },
    );
  }

  @override
  FutureEither<String?> uploadLogo(File logoFile) async {
    if (AppConfig.useMockData) {
      return right('https://images.unsplash.com/photo-1578916171728-46686eac8d58');
    }
    return _authService.uploadLogo(logoFile);
  }

  @override
  FutureEither<Map<String, dynamic>> switchBusiness({
    required String businessId,
    required String pin,
  }) async {
    if (AppConfig.useMockData) {
      final user = AppUser(
        id: 'mock-user-123',
        email: 'owner@gnade.com',
        name: 'Gnade Owner',
        businessId: businessId,
        role: 'owner',
      );
      _currentMockUser = user;
      _mockUserStreamController.add(_currentMockUser);
      return right({
        'business_id': businessId,
        'role': 'owner',
      });
    }

    return _authService.switchBusiness(
      businessId: businessId,
      pin: pin,
    );
  }

  @override
  FutureEither<void> setBusinessPin({
    required String businessId,
    required String pin,
  }) async {
    if (AppConfig.useMockData) return right(null);
    return _authService.setBusinessPin(
      businessId: businessId,
      pin: pin,
    );
  }
}
