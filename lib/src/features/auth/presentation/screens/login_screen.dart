import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    Future<void> handleLogin() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      
      ref.read(authControllerProvider.notifier).login(
        context: context, 
        email: _emailController.text, 
        password: _passwordController.text,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Storefront Rounded Square Badge
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 32.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Welcome Back Title
                  Text(
                    'auth.welcome_back'.tr(),
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      fontSize: 26.sp,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.xs.h),
                  
                  // Subtitle
                  Text(
                    'auth.sign_in_to_continue'.tr(),
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.lg.h),
                  
                  // Email Input Field
                  AppTextField(
                    controller: _emailController,
                    enabled: !isLoading,
                    label: 'auth.email_or_employee_id'.tr(),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Icon(
                        Icons.person_outline_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'auth.email_or_employee_id_required'.tr();
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Password Input Field
                  AppTextField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    label: 'auth.password'.tr(),
                    obscureText: _obscurePassword,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'auth.password_required'.tr();
                      }
                      if (v!.length < 6) {
                        return 'auth.password_too_short'.tr();
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: AppSpacing.sm.h),
                  
                  // Forgot Password Link (aligned right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: Text(
                        'auth.forgot_password'.tr(),
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Login Button
                  AppButton(
                    label: 'auth.login_button'.tr(),
                    isLoading: isLoading,
                    onPressed: isLoading ? null : handleLogin,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Custom Or Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'or',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),
                  
                  // Quick PIN Login Button
                  AppButton(
                    label: 'auth.quick_pin_login'.tr(),
                    onPressed: isLoading ? null : () {
                      showToast(context, message: 'PIN Login coming soon!', status: 'info');
                    },
                    variant: ButtonVariant.outline,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: Icon(
                        Icons.dialpad_rounded,
                        size: 20.sp,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.md.h),

                  // Footer link to Signup Screen
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(AppRoutes.signup),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'auth.dont_have_account'.tr(),
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontSize: 14.sp,
                          ),
                          children: [
                            TextSpan(
                              text: 'auth.sign_up'.tr(),
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.xl.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
