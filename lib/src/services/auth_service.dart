import 'dart:io';
import '../utils/utils.dart';
import '../config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _supabaseClient => AppConfig.supabase;

  /// Stream of auth state changes. Emits the current user map or null.
  Stream<Map<String, dynamic>?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.map((data) {
      final session = data.session;
      if (session == null) return null;
      final user = session.user;
      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'] ?? '',
        'photoUrl': user.userMetadata?['avatar_url'],
      };
    });
  }

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return null;
      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'] ?? '',
        'photoUrl': user.userMetadata?['avatar_url'],
      };
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return runTask(() async {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          if (metadata != null) ...metadata,
        },
      );
      final user = response.user;
      if (user == null) return null;
      return {
        'id': user.id,
        'email': user.email,
        'name': name,
        'photoUrl': user.userMetadata?['avatar_url'],
      };
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _supabaseClient.auth.signOut();
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'] ?? '',
        'photoUrl': user.userMetadata?['avatar_url'],
      };
    });
  }

  /// Fetch the user's profile from the `users` table
  FutureEither<Map<String, dynamic>?> getUserProfile() async {
    return runTask(() async {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;
      final data = await _supabaseClient
          .from('users')
          .select('full_name, phone')
          .eq('id', userId)
          .maybeSingle();
      return data;
    }, requiresNetwork: true);
  }

  /// Fetch all businesses a user belongs to
  FutureEither<List<dynamic>> getBusinesses() async {
    return runTask(() async {
      final response = await _supabaseClient.rpc<List<dynamic>>('get_user_business_summaries');
      return response;
    }, requiresNetwork: true);
  }

  /// Create a new business and link to user
  FutureEither<Map<String, dynamic>> createBusiness({
    required String name,
    required String category,
    required String userName,
    required String userPhone,
    required String pin,
  }) async {
    return runTask(() async {
      final result = await _supabaseClient.rpc<Map<String, dynamic>>(
        'initialize_business',
        params: {
          'p_business_name': name,
          'p_business_category': category,
          'p_user_name': userName,
          'p_user_phone': userPhone,
          'p_pin': pin,
        },
      );
      // Force token refresh so client picks up session updates immediately
      await _supabaseClient.auth.refreshSession();
      return result;
    }, requiresNetwork: true);
  }

  /// Switch the active business by ID and verify PIN
  FutureEither<Map<String, dynamic>> switchBusiness({
    required String businessId,
    required String pin,
  }) async {
    return runTask(() async {
      final result = await _supabaseClient.rpc<Map<String, dynamic>>(
        'set_active_business',
        params: {
          'p_business_id': businessId,
          'p_pin': pin,
        },
      );
      // Force token refresh so the client picks up the new JWT with updated app_metadata.active_business_id
      await _supabaseClient.auth.refreshSession();
      return result;
    }, requiresNetwork: true);
  }

  FutureEither<void> clearActiveBusiness() async {
    return runTask(() async {
      await _supabaseClient.rpc<void>('clear_active_business');
      await _supabaseClient.auth.refreshSession();
    }, requiresNetwork: true);
  }

  /// Set or update the PIN for a business
  FutureEither<void> setBusinessPin({
    required String businessId,
    required String pin,
  }) async {
    return runTask(() async {
      await _supabaseClient.rpc<void>(
        'update_business_pin',
        params: {
          'p_business_id': businessId,
          'p_pin': pin,
        },
      );
    }, requiresNetwork: true);
  }

  /// Call the `initialize_business` RPC to atomically create a business + user row.
  /// Returns `{ business_id, role }` on success.
  @Deprecated('Use createBusiness instead')
  FutureEither<Map<String, dynamic>> initializeBusiness({
    required String businessName,
    String? businessCategory,
    required String userName,
    String? userPhone,
  }) async {
    return runTask(() async {
      final result = await _supabaseClient.rpc<Map<String, dynamic>>(
        'initialize_business',
        params: {
          'p_business_name': businessName,
          'p_business_category': businessCategory,
          'p_user_name': userName,
          'p_user_phone': userPhone,
          'p_pin': '',
        },
      );
      return result;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> getBusinessProfile(String businessId) async {
    return runTask(() async {
      final data = await _supabaseClient
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<String?> uploadLogo(File logoFile) async {
    return runTask(() async {
      final extension = logoFile.path.split('.').last;
      final path = 'public/${DateTime.now().millisecondsSinceEpoch}_logo.$extension';
      await _supabaseClient.storage.from('logos').upload(path, logoFile);
      final publicUrl = _supabaseClient.storage.from('logos').getPublicUrl(path);
      return publicUrl;
    }, requiresNetwork: true);
  }

  FutureEither<void> updateBusinessProfile({
    required String businessId,
    String? name,
    String? category,
    String? phone,
    String? address,
    String? logoUrl,
  }) async {
    return runTask(() async {
      await _supabaseClient.from('businesses').update({
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (logoUrl != null) 'logo_url': logoUrl,
      }).eq('id', businessId);
    }, requiresNetwork: true);
  }

  void dispose() {
    // Supabase manages its own streams
  }
}

