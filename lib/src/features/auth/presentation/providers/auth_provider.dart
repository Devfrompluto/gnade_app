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
          if (failure is EmailVerificationRequiredFailure) {
            showAppDialog<void>(
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 24.w),
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEBF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_read_outlined,
                            color: const Color(0xFF1A56DB),
                            size: 40.sp,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Check Your Email',
                          style: TextStyle(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'We\'ve sent a verification link to your email address. Please click the link to confirm your account, then log in to create your shop.',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 14.sp,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Go to Login',
                            onPressed: () {
                              Navigator.pop(rootContext!);
                              context.go(AppRoutes.login);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            showToast(context, message: failure.message, status: 'error');
          }
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
