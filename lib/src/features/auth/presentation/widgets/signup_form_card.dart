import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SignupFormCard extends StatefulWidget {
  const SignupFormCard({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLoading;
  final void Function({
    required String name,
    required String phoneNumber,
    required String email,
    required String password,
  }) onSubmit;

  @override
  State<SignupFormCard> createState() => _SignupFormCardState();
}

class _SignupFormCardState extends State<SignupFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedDialCode = '+234';

  final List<Map<String, String>> _countryCodes = const [
    {'name': 'Nigeria', 'flag': '🇳🇬', 'code': '+234'},
    {'name': 'Kenya', 'flag': '🇰🇪', 'code': '+254'},
    {'name': 'Ghana', 'flag': '🇬🇭', 'code': '+233'},
    {'name': 'South Africa', 'flag': '🇿🇦', 'code': '+27'},
    {'name': 'Rwanda', 'flag': '🇷🇼', 'code': '+250'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_agreedToTerms) {
      showToast(
        context,
        message: 'You must agree to the Terms and Conditions and Privacy Policy.',
        status: 'warning',
      );
      return;
    }

    widget.onSubmit(
      name: _nameController.text.trim(),
      phoneNumber: AppUtils.formatE164(_selectedDialCode, _phoneController.text.trim()),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name Input
            AppTextField(
              controller: _nameController,
              enabled: !widget.isLoading,
              label: 'Full Name',
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Full name is required'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Phone Number Input
            AppTextField(
              controller: _phoneController,
              enabled: !widget.isLoading,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDialCode,
                    isDense: true,
                    alignment: Alignment.center,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    items: _countryCodes.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['code'],
                        child: Text(
                          '${c['flag']} ${c['code']}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: widget.isLoading
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedDialCode = val;
                              });
                            }
                          },
                  ),
                ),
              ),
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Phone number is required'.tr();
                }
                final combined = AppUtils.formatE164(_selectedDialCode, v!.trim());
                if (!AppUtils.isPhoneNumber(combined)) {
                  return 'Invalid phone number'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Email Address Input
            AppTextField(
              controller: _emailController,
              enabled: !widget.isLoading,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Email is required'.tr();
                }
                if (!AppUtils.isValidEmail(v!)) {
                  return 'Invalid email address'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Password Input
            AppTextField(
              controller: _passwordController,
              enabled: !widget.isLoading,
              label: 'Password',
              obscureText: _obscurePassword,
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
                  return 'Password is required'.tr();
                }
                if (v!.length < 6) {
                  return 'Password must be at least 6 characters'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Confirm Password Input
            AppTextField(
              controller: _confirmPasswordController,
              enabled: !widget.isLoading,
              label: 'Confirm Password',
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Please confirm your password'.tr();
                }
                if (v != _passwordController.text) {
                  return 'Passwords do not match'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Terms and Conditions Checkbox Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: _agreedToTerms,
                    activeColor: const Color(0xFF1A56DB),
                    onChanged: widget.isLoading
                        ? null
                        : (val) {
                            setState(() {
                              _agreedToTerms = val ?? false;
                            });
                          },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        fontSize: 13.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: const Color(0xFF1A56DB),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: const Color(0xFF1A56DB),
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Create Account Button
            AppButton(
              label: 'Create Account',
              isLoading: widget.isLoading,
              isFullWidth: true,
              height: ButtonSize.medium,
              onPressed: widget.isLoading ? null : _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
