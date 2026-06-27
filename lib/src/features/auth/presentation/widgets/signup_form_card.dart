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
    required String businessName,
    required String businessCategory,
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
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCategory;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  final List<String> _categories = const [
    'Retail',
    'Wholesale',
    'Restaurant / Food',
    'Services',
    'Apparel / Fashion',
    'Electronics',
    'Supermarket / Grocery',
    'Beauty / Cosmetics',
    'Pharmacy / Healthcare',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
      businessName: _businessNameController.text.trim(),
      businessCategory: _selectedCategory ?? 'Other',
      phoneNumber: _phoneController.text.trim(),
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

            // Business Name Input
            AppTextField(
              controller: _businessNameController,
              enabled: !widget.isLoading,
              label: 'Business Name',
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Business name is required'.tr();
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Business Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              hint: Text(
                'Business Category',
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                );
              }).toList(),
              onChanged: widget.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              validator: (v) => v == null ? 'Business category is required'.tr() : null,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                isDense: true,
              ),
            ),
            SizedBox(height: 16.h),

            // Phone Number Input
            AppTextField(
              controller: _phoneController,
              enabled: !widget.isLoading,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (AppUtils.isBlank(v)) {
                  return 'Phone number is required'.tr();
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

            // Create My Shop Button
            AppButton(
              label: 'Create My Shop',
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
