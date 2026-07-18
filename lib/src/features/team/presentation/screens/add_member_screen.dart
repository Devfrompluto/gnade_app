import 'dart:math' as math;
import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/team_provider.dart';
import '../widgets/role_selector_widget.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtr   = TextEditingController();
  final _phoneCtr  = TextEditingController();
  final _emailCtr  = TextEditingController();
  final _pinCtr    = TextEditingController();
  final _pinCtr2   = TextEditingController();
  final _employeeIdCtr = TextEditingController();
  String _role     = 'staff';
  bool _obscurePin = true;

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _emailCtr.dispose();
    _pinCtr.dispose();
    _pinCtr2.dispose();
    _employeeIdCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch<AsyncValue<void>>(addMemberProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppTopBar(title: 'Add Staff Member'),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // 1. Personal Details
                  const Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _nameCtr,
                    hint: 'e.g. John Doe',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    textCapitalization: TextCapitalization.words,
                    fillColor: Colors.white,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _phoneCtr,
                    hint: '080...',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    keyboardType: TextInputType.phone,
                    fillColor: Colors.white,
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _emailCtr,
                    hint: 'e.g. john@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    keyboardType: TextInputType.emailAddress,
                    fillColor: Colors.white,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Employee ID (Optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _employeeIdCtr,
                    hint: 'e.g. EMP-0003 or custom ID',
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                    fillColor: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. Role
                  const Text(
                    'Role',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a role for this staff member',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RoleSelectorWidget(
                    selected: _role,
                    onSelected: (role) => setState(() => _role = role),
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. Access PIN
                  const Text(
                    'Access PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Staff will use this PIN to access this business',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Create PIN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _pinCtr,
                    hint: '....',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                    ),
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    fillColor: Colors.white,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      if (v == null || v.length < 4) return 'PIN must be at least 4 digits';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Confirm PIN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppTextField(
                    controller: _pinCtr2,
                    hint: '....',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    obscureText: _obscurePin,
                    keyboardType: TextInputType.number,
                    fillColor: Colors.white,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) =>
                        v != _pinCtr.text ? 'PINs do not match' : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Bottom button container
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                child: AppButton(
                  label: 'Add Staff Member',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: isLoading ? null : _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final sessionState = ref.read<SessionState>(sessionProvider);
    final businessId = sessionState.user?.businessId ?? '';
    
    var employeeId = _employeeIdCtr.text.trim();
    if (employeeId.isEmpty) {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rnd = math.Random();
      final randomStr = String.fromCharCodes(Iterable.generate(
          5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
      employeeId = 'EMP-$randomStr';
    }

    final success = await ref.read<AddMemberNotifier>(addMemberProvider.notifier).addMember(
      businessId: businessId,
      fullName:   _nameCtr.text.trim(),
      phone:      _phoneCtr.text.trim(),
      email:      _emailCtr.text.trim(),
      employeeId: employeeId,
      role:       _role,
      pin:        _pinCtr.text,
      ref:        ref,
    );

    if (success && mounted) context.pop();
  }
}
