import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/auth/domain/entities/user.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    repository: ref.read(authRepositoryProvider),
    ref: ref,
  );
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController({
    required AuthRepository repository,
    required Ref ref,
  })  : _repository = repository,
        _ref = ref,
        super(false); // loading state is false

  FutureEither<AppUser> login({required String email, required String password}) async {
    state = true;
    
    final result = await _repository.login(email: email, password: password);
    
    state = false;
    return result.fold(
      (failure) async => left(failure),
      (user) async {
        // Brief delay to mitigate "JWT issued at future" clock-skew errors
        // that occur when the device clock is slightly ahead of the server.
        await Future<void>.delayed(const Duration(milliseconds: 500));

        // Refresh session to read active_business_id from JWT appMetadata
        await _ref.read(sessionProvider.notifier).refresh();

        return right(user);
      },
    );
  }

  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    state = true;
    
    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
    
    state = false;
    return result;
  }

  FutureEither<void> switchBusiness({
    required String businessId,
    required String pin,
  }) async {
    state = true;
    final result = await _repository.switchBusiness(businessId: businessId, pin: pin);
    state = false;
    
    return result.fold(
      (failure) async => left(failure),
      (data) async {
        await _ref.read(sessionProvider.notifier).refresh();
        return right(null);
      },
    );
  }

  FutureEither<void> createBusiness({
    required String name,
    required String category,
    required String userName,
    required String userPhone,
    required String pin,
    String? phone,
    String? address,
    String? logoUrl,
  }) async {
    state = true;
    final result = await _repository.createBusiness(
      name: name,
      category: category,
      userName: userName,
      userPhone: userPhone,
      pin: pin,
      phone: phone,
      address: address,
      logoUrl: logoUrl,
    );
    state = false;

    return result.fold(
      (failure) async => left(failure),
      (data) async {
        await _ref.read(sessionProvider.notifier).refresh();
        return right(null);
      },
    );
  }

  Future<String?> uploadLogo(File logoFile) async {
    final result = await _repository.uploadLogo(logoFile);
    return result.fold(
      (failure) => null,
      (url) => url,
    );
  }

  FutureEither<void> forgotPassword({required String email}) async {
    state = true;
    
    final result = await _repository.forgotPassword(email: email);

    state = false;
    return result;
  }

  FutureEither<void> updateBusinessProfile({
    required String businessId,
    String? name,
    String? category,
    String? phone,
    String? address,
  }) async {
    state = true;
    final result = await _repository.updateBusinessProfile(
      businessId: businessId,
      name: name,
      category: category,
      phone: phone,
      address: address,
    );
    state = false;

    return result.fold(
      (failure) async => left(failure),
      (success) async {
        _ref.invalidate(businessProfileProvider);
        return right(null);
      },
    );
  }

  FutureEither<void> clearActiveBusiness() async {
    state = true;
    final result = await _repository.clearActiveBusiness();
    state = false;

    return result.fold(
      (failure) async => left(failure),
      (success) async {
        await _ref.read(sessionProvider.notifier).refresh();
        return right(null);
      },
    );
  }
}

final userBusinessesProvider = FutureProvider.autoDispose<List<BusinessSummary>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final result = await repo.getBusinesses();
  return result.fold(
    (failure) => throw failure,
    (businesses) => businesses,
  );
});

