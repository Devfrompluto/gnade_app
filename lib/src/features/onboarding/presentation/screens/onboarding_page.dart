import 'package:gnade_app/src/imports/imports.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Centered App Icon Badge
              Center(
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      icon: HugeIcons.strokeRoundedShoppingBag02,
                      size: 44.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.xxl.h),
              
              // App Title
              Text(
                'onboarding.title'.tr(),
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                  fontSize: 28.sp,
                  letterSpacing: -0.5,
                ),
              ),
              
              SizedBox(height: AppSpacing.sm.h),
              
              // Subtitle
              Text(
                'onboarding.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 15.sp,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Get Started Button
              AppButton(
                label: 'shared.get_started'.tr(),
                onPressed: () => context.go(AppRoutes.login),
                variant: ButtonVariant.primary,
                height: ButtonSize.large,
                isFullWidth: true,
              ),
              
              SizedBox(height: AppSpacing.lg.h),
              
              // Already have an account? Sign In
              GestureDetector(
                onTap: () => context.go(AppRoutes.login),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs.h),
                  child: RichText(
                    text: TextSpan(
                      text: 'auth.already_have_account'.tr(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'auth.sign_in'.tr(),
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: AppSpacing.lg.h),
            ],
          ),
        ),
      ),
    );
  }
}
