import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_pin_keyboard.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_pin_dots.dart';

class PinEntryBottomSheet extends ConsumerStatefulWidget {
  final BusinessSummary business;

  const PinEntryBottomSheet({
    super.key,
    required this.business,
  });

  static Future<bool?> show(BuildContext context, BusinessSummary business) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinEntryBottomSheet(business: business),
    );
  }

  @override
  ConsumerState<PinEntryBottomSheet> createState() => _PinEntryBottomSheetState();
}

class _PinEntryBottomSheetState extends ConsumerState<PinEntryBottomSheet> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _isLoading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPress(String val) {
    if (_isLoading) return;
    if (_pin.length < 4) {
      setState(() {
        _pin += val;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_isLoading) return;
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    final success = await ref.read(authControllerProvider.notifier).switchBusiness(
          context: context,
          businessId: widget.business.id,
          pin: _pin,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _pin = '';
        });
        _shakeController.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        top: 16.h,
        left: 24.w,
        right: 24.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Business Details Header
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    widget.business.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A56DB),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.business.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.business.category ?? 'Retail',
                      style: tt.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Prompt
          Text(
            'Enter Quick PIN to access business',
            style: tt.bodyMedium?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.h),

          // PIN Indicators (with shake animation)
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value * (1 - (_shakeController.value * 2)), 0),
                child: AuthPinDots(pinLength: _pin.length),
              );
            },
          ),
          SizedBox(height: 32.h),

          // Keyboard / Number Pad
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
            AuthPinKeyboard(
              onKeyPress: _onKeyPress,
              onBackspace: _onBackspace,
            ),
        ],
      ),
    );
  }
}
