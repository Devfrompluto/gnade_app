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
  }) async {
    return runTask(() async {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
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
      final session = _supabaseClient.auth.currentSession;
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

  /// Fetch the user's profile from the `users` table (business_id, role, etc.)
  FutureEither<Map<String, dynamic>?> getUserProfile() async {
    return runTask(() async {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) return null;
      final data = await _supabaseClient
          .from('users')
          .select('business_id, full_name, phone, role')
          .eq('id', userId)
          .maybeSingle();
      return data;
    });
  }

  /// Call the `initialize_business` RPC to atomically create a business + user row.
  /// Returns `{ business_id, role }` on success.
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
        },
      );
      return result;
    }, requiresNetwork: true);
  }

  void dispose() {
    // Supabase manages its own streams
  }
}
