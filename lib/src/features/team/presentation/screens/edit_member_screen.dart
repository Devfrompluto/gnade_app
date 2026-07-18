import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/team_provider.dart';
import '../widgets/role_selector_widget.dart';

class EditMemberScreen extends ConsumerStatefulWidget {
  final StaffMember member;

  const EditMemberScreen({
    required this.member,
    super.key,
  });

  @override
  ConsumerState<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends ConsumerState<EditMemberScreen> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _nameCtr;
  late final TextEditingController _phoneCtr;
  late String _role;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.member.fullName);
    _phoneCtr = TextEditingController(text: widget.member.phone);
    _role = widget.member.role;
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch<AsyncValue<void>>(memberActionProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppTopBar(title: 'Edit Staff Member'),
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
                  label: 'Save Details',
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

    final success = await ref.read<MemberActionNotifier>(memberActionProvider.notifier).updateMember(
      memberId: widget.member.id,
      fullName: _nameCtr.text.trim(),
      phone: _phoneCtr.text.trim(),
      role: _role,
      businessId: businessId,
      ref: ref,
    );

    if (success && mounted) context.pop();
  }
}
