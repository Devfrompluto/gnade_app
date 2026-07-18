import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeLoginScreen extends ConsumerStatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  ConsumerState<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends ConsumerState<EmployeeLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdCtr = TextEditingController();
  final _pinCtr = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _employeeIdCtr.dispose();
    _pinCtr.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final employeeId = _employeeIdCtr.text.trim().toUpperCase();
      final pin = _pinCtr.text.trim();

      // 1. Look up the internal email for this employee ID via RPC
      final email = await Supabase.instance.client
          .rpc<dynamic>('get_employee_login_email', params: {'p_employee_id': employeeId});

      if (email == null || (email is String && email.isEmpty)) {
        if (mounted) {
          showToast(context, message: 'Employee ID not found', status: 'error');
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Sign in with the internal email and PIN
      final result = await ref.read(authControllerProvider.notifier).login(
        email: email as String,
        password: pin,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          showToast(context, message: 'Invalid PIN or account inactive', status: 'error');
        },
        (user) {
          final session = ref.read(sessionProvider);
          if (session.status == SessionStatus.authenticated) {
            context.go(AppRoutes.dashboard);
          } else {
            context.go(AppRoutes.selectBusiness);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        showToast(context, message: 'Login failed. Please try again.', status: 'error');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

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

                  // Badge icon
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E), // teal
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.badge_outlined,
                          size: 32.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md.h),

                  // Title
                  Text(
                    'Staff Login',
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
                    'Enter your Employee ID and PIN to access your business',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                      fontSize: 14.sp,
                    ),
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // Employee ID field
                  AppTextField(
                    controller: _employeeIdCtr,
                    enabled: !_isLoading,
                    label: 'Employee ID',
                    textCapitalization: TextCapitalization.characters,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Icon(
                        Icons.badge_outlined,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'Employee ID is required';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.md.h),

                  // PIN field
                  AppTextField(
                    controller: _pinCtr,
                    enabled: !_isLoading,
                    label: 'PIN',
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                    ),
                    validator: (v) {
                      if (AppUtils.isBlank(v)) {
                        return 'PIN is required';
                      }
                      if (v!.length < 4) {
                        return 'PIN must be at least 4 digits';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // Login button
                  AppButton(
                    label: 'Login',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleLogin,
                    height: ButtonSize.medium,
                    isFullWidth: true,
                  ),

                  SizedBox(height: AppSpacing.lg.h),

                  // Back to owner login
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Business owner? ',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                            fontSize: 14.sp,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login here',
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
