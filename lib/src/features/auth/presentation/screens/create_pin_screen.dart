import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_pin_dots.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_pin_keyboard.dart';

class CreatePinScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> businessDetails;

  const CreatePinScreen({
    super.key,
    required this.businessDetails,
  });

  @override
  ConsumerState<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends ConsumerState<CreatePinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onKeyPress(String val) {
    if (_isLoading) return;

    if (!_isConfirming) {
      if (_firstPin.length < 4) {
        setState(() {
          _firstPin += val;
        });

        if (_firstPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              _isConfirming = true;
            });
          });
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() {
          _confirmPin += val;
        });

        if (_confirmPin.length == 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _handleSave();
          });
        }
      }
    }
  }

  void _onBackspace() {
    if (_isLoading) return;

    if (!_isConfirming) {
      if (_firstPin.isNotEmpty) {
        setState(() {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        });
      }
    } else {
      if (_confirmPin.isNotEmpty) {
        setState(() {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (_firstPin != _confirmPin) {
      showToast(context, message: 'PINs do not match. Try again.', status: 'error');
      setState(() {
        _firstPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final details = widget.businessDetails;
    final logoFile = details['logoFile'] as File?;
    String? logoUrl;

    if (logoFile != null) {
      logoUrl = await ref.read(authControllerProvider.notifier).uploadLogo(logoFile);
      if (logoUrl == null) {
        if (mounted) {
          showToast(context, message: 'Failed to upload logo. Try again.', status: 'error');
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
    }

    if (!mounted) return;

    final success = await ref.read(authControllerProvider.notifier).createBusiness(
          context: context,
          name: details['name'] as String,
          category: details['category'] as String,
          userName: ref.read(sessionProvider).user?.name ?? 'Owner',
          userPhone: ref.read(sessionProvider).user?.photoUrl ?? '',
          pin: _confirmPin,
          phone: details['phone'] as String?,
          address: details['address'] as String?,
          logoUrl: logoUrl,
        );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (success && context.mounted) {
      context.go(AppRoutes.selectBusiness);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;
    final currentPin = _isConfirming ? _confirmPin : _firstPin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A56DB)),
          onPressed: () {
            if (_isConfirming) {
              setState(() {
                _confirmPin = '';
                _isConfirming = false;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Set Business PIN',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isConfirming ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                        color: const Color(0xFF1A56DB),
                        size: 36.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      _isConfirming ? 'Confirm Your PIN' : 'Create Business PIN',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        fontSize: 24.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _isConfirming
                          ? 'Please re-enter the 4-digit PIN to confirm'
                          : 'Set a 4-digit security PIN to restrict access to this business profile',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                    ),
                    SizedBox(height: 48.h),

                    // Dot Indicators
                    AuthPinDots(pinLength: currentPin.length),
                  ],
                ),
              ),
            ),

            // Keyboard at the bottom
            if (_isLoading)
              SizedBox(
                height: 280.h,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1A56DB),
                  ),
                ),
              )
            else
              Container(
                color: const Color(0xFFF8FAFC),
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
                child: AuthPinKeyboard(
                  onKeyPress: _onKeyPress,
                  onBackspace: _onBackspace,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
