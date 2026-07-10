import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import '../widgets/signup_form_card.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    final cs = context.colors;
    final tt = context.textTheme;

    Future<void> handleSignup({
      required String name,
      required String phoneNumber,
      required String email,
      required String password,
    }) async {
      final result = await ref.read(authControllerProvider.notifier).signUp(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
          );

      if (!context.mounted) return;

      result.fold(
        (failure) {
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
        },
        (user) {
          context.go(AppRoutes.selectBusiness);
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: const Color(0xFF1A56DB),
            size: 24.sp,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.login);
            }
          },
        ),
        title: Text(
          'Kinetic Retail',
          style: tt.titleLarge?.copyWith(
            color: const Color(0xFF1A56DB),
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Container(
            color: cs.outlineVariant.withValues(alpha: 0.3),
            height: 1.h,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.h),

              // Title
              Text(
                'Create Account',
                style: tt.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  fontSize: 26.sp,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6.h),

              // Subtitle
              Text(
                'Set up your shop profile to get started.',
                style: tt.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Form Card Widget
              SignupFormCard(
                isLoading: isLoading,
                onSubmit: handleSignup,
              ),
              SizedBox(height: 24.h),

              // Footer: Already have an account? Sign In
              Center(
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => context.go(AppRoutes.login),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: tt.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: const Color(0xFF1A56DB),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
