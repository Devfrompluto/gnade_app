import 'dart:io';
import 'package:gnade_app/src/utils/utils.dart';
import 'package:gnade_app/src/features/auth/domain/entities/user.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_profile.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';

abstract class AuthRepository {
  /// Stream of auth state changes. Emits AppUser when authenticated, null when not.
  Stream<AppUser?> get onAuthStateChanged;

  /// Sign in with email and password
  FutureEither<AppUser> login({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and phone number
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  });

  /// Send a password reset email
  FutureEither<void> forgotPassword({
    required String email,
  });

  /// Sign out the current user
  FutureEither<void> logout();
  
  /// Check if the user is currently authenticated natively
  FutureEither<AppUser?> checkAuthState();

  /// Retrieve the profile of a business by ID
  FutureEither<BusinessProfile> getBusinessProfile(String businessId);

  /// Fetch all businesses a user belongs to
  FutureEither<List<BusinessSummary>> getBusinesses();

  /// Create a new business and link to user
  FutureEither<Map<String, dynamic>> createBusiness({
    required String name,
    required String category,
    required String userName,
    required String userPhone,
    required String pin,
    String? phone,
    String? address,
    String? logoUrl,
  });

  /// Upload business logo to storage
  FutureEither<String?> uploadLogo(File logoFile);

  /// Switch the active business by ID and verify PIN
  FutureEither<Map<String, dynamic>> switchBusiness({
    required String businessId,
    required String pin,
  });

  /// Set or update the PIN for a business
  FutureEither<void> setBusinessPin({
    required String businessId,
    required String pin,
  });
}


