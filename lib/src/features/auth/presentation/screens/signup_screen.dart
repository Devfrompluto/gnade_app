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
      required String businessName,
      required String businessCategory,
      required String phoneNumber,
      required String email,
      required String password,
    }) async {
      ref.read(authControllerProvider.notifier).signUp(
            context: context,
            name: name,
            email: email,
            password: password,
            businessName: businessName,
            businessCategory: businessCategory,
            phoneNumber: phoneNumber,
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
