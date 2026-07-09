import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';
import 'package:gnade_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

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
                          'We\'ve sent a verification link to your email address. Please click the link to confirm your account, then log in to create or select your business.',
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
          rootContext!.go(AppRoutes.selectBusiness);
        }
      },
    );
  }

  Future<bool> switchBusiness({
    required BuildContext context,
    required String businessId,
    required String pin,
  }) async {
    state = true;
    final result = await _repository.switchBusiness(businessId: businessId, pin: pin);
    state = false;
    
    return result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
        return false;
      },
      (data) async {
        await _ref.read(sessionProvider.notifier).refresh();
        return true;
      },
    );
  }

  Future<bool> createBusiness({
    required BuildContext context,
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
      (failure) {
        showToast(context, message: failure.message, status: 'error');
        return false;
      },
      (data) async {
        showToast(context, message: 'Business created successfully!', status: 'success');
        await _ref.read(sessionProvider.notifier).refresh();
        return true;
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

final userBusinessesProvider = FutureProvider.autoDispose<List<BusinessSummary>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final result = await repo.getBusinesses();
  return result.fold(
    (failure) => throw failure,
    (businesses) => businesses,
  );
});

