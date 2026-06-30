import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(false); // loading state is false

  void login({required BuildContext context, required String email, required String password}) async {
    state = true;
    
    final result = await _repository.login(email: email, password: password);
    
    state = false;
    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (user) {
        if (rootContext?.mounted ?? false) {
          rootContext!.go(AppRoutes.dashboard);
        }
      },
    );
  }

  void signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String businessName,
    required String businessCategory,
    required String phoneNumber,
  }) async {
    state = true;
    
    final result = await _repository.signUp(
      name: name,
      email: email,
      password: password,
      businessName: businessName,
      businessCategory: businessCategory,
      phoneNumber: phoneNumber,
    );
    
    state = false;
    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (user) {
        if (rootContext?.mounted ?? false) {
          rootContext!.go(AppRoutes.dashboard);
        }
      },
    );
  }

  void forgotPassword({required BuildContext context, required String email}) async {
    state = true;
    
    final result = await _repository.forgotPassword(email: email);

    state = false;
    result.fold(
      (failure) {
        if (context.mounted) {
          showToast(context, message: failure.message, status: 'error');
        }
      },
      (success) {
        if (context.mounted) {
          showToast(context, message: 'Password reset link sent successfully', status: 'success');
        }
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
    );
  }
}
