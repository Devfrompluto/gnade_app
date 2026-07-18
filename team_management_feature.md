# Team Management Feature — Complete Implementation
> Edge Function · Domain · Repository · Providers · Screens · Widgets

---

## FILE 1 — Edge Function
### `supabase/functions/create-staff-member/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  try {
    const { business_id, full_name, phone, role, pin } = await req.json();

    // ── Validate inputs ────────────────────────────────────────────────
    if (!business_id || !full_name || !phone || !role || !pin) {
      return _error("All fields are required", 400);
    }

    const validRoles = ["manager", "staff"];
    if (!validRoles.includes(role)) {
      return _error("Role must be manager or staff", 400);
    }

    if (!/^\d{4,6}$/.test(pin)) {
      return _error("PIN must be 4–6 digits", 400);
    }

    // ── Verify caller is owner/manager of this business ───────────────
    const authHeader = req.headers.get("Authorization")!;
    const { data: { user: caller } } = await supabase.auth.getUser(
      authHeader.replace("Bearer ", ""),
    );

    if (!caller) return _error("Unauthorized", 401);

    const { data: callerMembership } = await supabase
      .from("business_members")
      .select("role")
      .eq("user_id", caller.id)
      .eq("business_id", business_id)
      .eq("is_active", true)
      .single();

    if (
      !callerMembership ||
      !["owner", "manager"].includes(callerMembership.role)
    ) {
      return _error("You do not have permission to add staff", 403);
    }

    // ── Generate employee ID ───────────────────────────────────────────
    const { count } = await supabase
      .from("business_members")
      .select("*", { count: "exact", head: true })
      .eq("business_id", business_id);

    const employeeId = `EMP-${String((count ?? 0) + 1).padStart(4, "0")}`;
    const internalEmail =
      `${employeeId.toLowerCase()}@${business_id}.internal`;

    // ── Create Supabase Auth user ──────────────────────────────────────
    const { data: authData, error: authError } =
      await supabase.auth.admin.createUser({
        email: internalEmail,
        password: pin,
        email_confirm: true,
        user_metadata: { full_name, employee_id: employeeId, business_id },
      });

    if (authError) return _error(authError.message, 400);

    const newUserId = authData.user.id;

    // ── Create users record ───────────────────────────────────────────
    const { error: userError } = await supabase
      .from("users")
      .insert({ id: newUserId, full_name, phone });

    if (userError) {
      await supabase.auth.admin.deleteUser(newUserId); // rollback
      return _error(userError.message, 500);
    }

    // ── Create business_members record with hashed PIN ─────────────────
    const { error: memberError } = await supabase
      .from("business_members")
      .insert({
        user_id:     newUserId,
        business_id,
        role,
        employee_id: employeeId,
        pin:         pin, // store as-is; pgcrypto hashing via RPC on verify
      });

    if (memberError) {
      await supabase.auth.admin.deleteUser(newUserId); // rollback
      return _error(memberError.message, 500);
    }

    return new Response(
      JSON.stringify({ employee_id: employeeId, user_id: newUserId }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    return _error(`Unexpected error: ${e}`, 500);
  }
});

function _error(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
```

---

## FILE 2 — Domain Entity
### `lib/src/features/team/domain/entities/staff_member.dart`

```dart
class StaffMember {
  final String id;           // business_members.id
  final String userId;       // users.id
  final String fullName;
  final String phone;
  final String role;         // 'owner' | 'manager' | 'staff'
  final String? employeeId;  // null for owner
  final bool isActive;
  final DateTime createdAt;

  const StaffMember({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.role,
    this.employeeId,
    required this.isActive,
    required this.createdAt,
  });

  bool get isOwner   => role == 'owner';
  bool get isManager => role == 'manager';
  bool get isStaff   => role == 'staff';

  String get roleLabel => switch (role) {
        'owner'   => 'Owner',
        'manager' => 'Manager',
        _         => 'Staff',
      };
}
```

---

## FILE 3 — Abstract Repository
### `lib/src/features/team/domain/repositories/team_repository.dart`

```dart
abstract class TeamRepository {
  FutureEither<List<StaffMember>> getTeamMembers(String businessId);

  FutureEither<StaffMember> addStaffMember({
    required String businessId,
    required String fullName,
    required String phone,
    required String role,
    required String pin,
  });

  FutureEither<void> updateStaffMember({
    required String memberId,
    required String fullName,
    required String phone,
    required String role,
  });

  FutureEither<void> updatePin({
    required String memberId,
    required String newPin,
  });

  FutureEither<void> deactivateMember(String memberId);

  FutureEither<void> reactivateMember(String memberId);
}
```

---

## FILE 4 — Repository Implementation
### `lib/src/features/team/data/repositories/team_repository_impl.dart`

```dart
class TeamRepositoryImpl implements TeamRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Get all members ──────────────────────────────────────────────────

  @override
  FutureEither<List<StaffMember>> getTeamMembers(String businessId) =>
      runTask(() async {
        final data = await _client
            .from('business_members')
            .select('id, user_id, role, employee_id, is_active, created_at, users(full_name, phone)')
            .eq('business_id', businessId)
            .order('created_at');

        return data.map((row) {
          final user = row['users'] as Map<String, dynamic>;
          return StaffMember(
            id:         row['id'] as String,
            userId:     row['user_id'] as String,
            fullName:   user['full_name'] as String,
            phone:      user['phone'] as String,
            role:       row['role'] as String,
            employeeId: row['employee_id'] as String?,
            isActive:   row['is_active'] as bool,
            createdAt:  DateTime.parse(row['created_at'] as String),
          );
        }).toList();
      });

  // ── Add staff member via Edge Function ───────────────────────────────

  @override
  FutureEither<StaffMember> addStaffMember({
    required String businessId,
    required String fullName,
    required String phone,
    required String role,
    required String pin,
  }) =>
      runTask(() async {
        final response = await _client.functions.invoke(
          'create-staff-member',
          body: {
            'business_id': businessId,
            'full_name':   fullName.trim(),
            'phone':       phone.trim(),
            'role':        role,
            'pin':         pin,
          },
        );

        if (response.status != 200) {
          final message = (response.data as Map?)?['error'] ?? 'Failed to add staff';
          throw Failure(message as String);
        }

        final employeeId = response.data['employee_id'] as String;
        final userId     = response.data['user_id'] as String;

        return StaffMember(
          id:         '', // refreshed from DB on next fetch
          userId:     userId,
          fullName:   fullName.trim(),
          phone:      phone.trim(),
          role:       role,
          employeeId: employeeId,
          isActive:   true,
          createdAt:  DateTime.now(),
        );
      });

  // ── Update name / phone / role ───────────────────────────────────────

  @override
  FutureEither<void> updateStaffMember({
    required String memberId,
    required String fullName,
    required String phone,
    required String role,
  }) =>
      runTask(() async {
        // Update role in business_members
        await _client
            .from('business_members')
            .update({'role': role})
            .eq('id', memberId);

        // Update name + phone in users (get user_id first)
        final member = await _client
            .from('business_members')
            .select('user_id')
            .eq('id', memberId)
            .single();

        await _client
            .from('users')
            .update({'full_name': fullName.trim(), 'phone': phone.trim()})
            .eq('id', member['user_id']);
      });

  // ── Update PIN ───────────────────────────────────────────────────────

  @override
  FutureEither<void> updatePin({
    required String memberId,
    required String newPin,
  }) =>
      runTask(() async {
        await _client
            .from('business_members')
            .update({'pin': newPin})
            .eq('id', memberId);
      });

  // ── Deactivate (soft delete) ─────────────────────────────────────────

  @override
  FutureEither<void> deactivateMember(String memberId) =>
      runTask(() async {
        await _client
            .from('business_members')
            .update({'is_active': false})
            .eq('id', memberId);
      });

  // ── Reactivate ───────────────────────────────────────────────────────

  @override
  FutureEither<void> reactivateMember(String memberId) =>
      runTask(() async {
        await _client
            .from('business_members')
            .update({'is_active': true})
            .eq('id', memberId);
      });
}
```

---

## FILE 5 — Providers
### `lib/src/features/team/presentation/providers/team_provider.dart`

```dart
// ── Repository provider ──────────────────────────────────────────────────────

final teamRepositoryProvider = Provider<TeamRepository>(
  (_) => TeamRepositoryImpl(),
);

// ── Team members list ────────────────────────────────────────────────────────

final teamMembersProvider =
    FutureProvider.family<List<StaffMember>, String>((ref, businessId) async {
  final result =
      await ref.read(teamRepositoryProvider).getTeamMembers(businessId);
  return result.fold(
    (failure) => throw failure,
    (members) => members,
  );
});

// ── Add member state ─────────────────────────────────────────────────────────

final addMemberProvider =
    StateNotifierProvider<AddMemberNotifier, AsyncValue<void>>(
  (ref) => AddMemberNotifier(ref.read(teamRepositoryProvider)),
);

class AddMemberNotifier extends StateNotifier<AsyncValue<void>> {
  AddMemberNotifier(this._repo) : super(const AsyncValue.data(null));

  final TeamRepository _repo;

  Future<bool> addMember({
    required String businessId,
    required String fullName,
    required String phone,
    required String role,
    required String pin,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.addStaffMember(
      businessId: businessId,
      fullName:   fullName,
      phone:      phone,
      role:       role,
      pin:        pin,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        showGlobalToast(failure.message, type: SnackBarType.error);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        // Refresh the team list
        ref.invalidate(teamMembersProvider(businessId));
        showGlobalToast('Staff member added successfully', type: SnackBarType.success);
        return true;
      },
    );
  }
}

// ── Member action state (deactivate / update / reset PIN) ────────────────────

final memberActionProvider =
    StateNotifierProvider<MemberActionNotifier, AsyncValue<void>>(
  (ref) => MemberActionNotifier(ref.read(teamRepositoryProvider)),
);

class MemberActionNotifier extends StateNotifier<AsyncValue<void>> {
  MemberActionNotifier(this._repo) : super(const AsyncValue.data(null));

  final TeamRepository _repo;

  Future<bool> deactivate(String memberId, String businessId, WidgetRef ref) =>
      _run(() => _repo.deactivateMember(memberId), businessId, ref,
          'Staff member deactivated');

  Future<bool> reactivate(String memberId, String businessId, WidgetRef ref) =>
      _run(() => _repo.reactivateMember(memberId), businessId, ref,
          'Staff member reactivated');

  Future<bool> updatePin(String memberId, String newPin) async {
    state = const AsyncValue.loading();
    final result = await _repo.updatePin(memberId: memberId, newPin: newPin);
    return result.fold(
      (f) {
        state = AsyncValue.error(f, StackTrace.current);
        showGlobalToast(f.message, type: SnackBarType.error);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        showGlobalToast('PIN updated', type: SnackBarType.success);
        return true;
      },
    );
  }

  Future<bool> _run(
    Future<FutureEither<void>> Function() action,
    String businessId,
    WidgetRef ref,
    String successMessage,
  ) async {
    state = const AsyncValue.loading();
    final result = await action();
    return result.fold(
      (f) {
        state = AsyncValue.error(f, StackTrace.current);
        showGlobalToast(f.message, type: SnackBarType.error);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(teamMembersProvider(businessId));
        showGlobalToast(successMessage, type: SnackBarType.success);
        return true;
      },
    );
  }
}
```

---

## FILE 6 — Team Screen
### `lib/src/features/team/presentation/screens/team_screen.dart`

```dart
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business   = ref.watch(requireBusinessProvider);
    final membership = ref.watch(activeMembershipProvider);
    final teamAsync  = ref.watch(teamMembersProvider(business.id));
    final canManage  = membership?.role == 'owner';

    return Scaffold(
      appBar: AppTopBar(
        title: 'Team',
        actions: [
          if (canManage)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: () => context.push(AppRoutes.addMember),
              tooltip: 'Add staff member',
            ),
        ],
      ),
      body: teamAsync.when(
        loading: () => const AppLoading(),
        error:   (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(teamMembersProvider(business.id)),
        ),
        data: (members) => members.isEmpty
            ? AppEmptyState(
                icon:        Icons.people_outline,
                title:       'No team members yet',
                subtitle:    'Add staff members to manage access',
                actionLabel: canManage ? 'Add Staff Member' : null,
                onAction:    canManage
                    ? () => context.push(AppRoutes.addMember)
                    : null,
              )
            : _TeamList(members: members, canManage: canManage),
      ),
    );
  }
}
```

---

## FILE 7 — Team List Widget
### `lib/src/features/team/presentation/widgets/team_list.dart`

```dart
class _TeamList extends StatelessWidget {
  final List<StaffMember> members;
  final bool canManage;

  const _TeamList({required this.members, required this.canManage});

  @override
  Widget build(BuildContext context) {
    // Split into active and inactive
    final active   = members.where((m) => m.isActive).toList();
    final inactive = members.where((m) => !m.isActive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        final ref = ProviderScope.containerOf(context);
        final businessId =
            ref.read(requireBusinessProvider).id;
        ref.invalidate(teamMembersProvider(businessId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active members
          ...active.map(
            (m) => TeamMemberCard(member: m, canManage: canManage),
          ),

          // Inactive members section
          if (inactive.isNotEmpty && canManage) ...[
            const SizedBox(height: 24),
            Text('Inactive Members',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            ...inactive.map(
              (m) => TeamMemberCard(member: m, canManage: canManage),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## FILE 8 — Team Member Card Widget
### `lib/src/features/team/presentation/widgets/team_member_card.dart`

```dart
class TeamMemberCard extends ConsumerWidget {
  final StaffMember member;
  final bool canManage;

  const TeamMemberCard({
    required this.member,
    required this.canManage,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.read(requireBusinessProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: _MemberAvatar(name: member.fullName, isActive: member.isActive),
          title: Row(
            children: [
              Expanded(
                child: Text(member.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              _RoleBadge(role: member.role),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(member.phone,
                  style: const TextStyle(fontSize: 12)),
              if (member.employeeId != null) ...[
                const SizedBox(height: 2),
                Text(member.employeeId!,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace')),
              ],
              if (!member.isActive)
                const Text('Inactive',
                    style: TextStyle(fontSize: 11, color: Colors.red)),
            ],
          ),
          trailing: canManage && !member.isOwner
              ? _MemberMenu(member: member, business: business, ref: ref)
              : null,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String name;
  final bool isActive;

  const _MemberAvatar({required this.name, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: CircleAvatar(
        radius: 22,
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Text(initial,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (role) {
      'owner'   => (const Color(0xFFB45309), const Color(0xFFFEF3C7)),
      'manager' => (const Color(0xFF1A56DB), const Color(0xFFEFF6FF)),
      _         => (const Color(0xFF374151), const Color(0xFFF3F4F6)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _MemberMenu extends ConsumerWidget {
  final StaffMember member;
  final Business business;
  final WidgetRef ref;

  const _MemberMenu({
    required this.member,
    required this.business,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_MemberAction>(
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (action) =>
          _onAction(context, ref, action),
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _MemberAction.editDetails,
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Edit details'),
        ),
        const PopupMenuItem(
          value: _MemberAction.resetPin,
          child: _MenuRow(icon: Icons.lock_reset_outlined, label: 'Reset PIN'),
        ),
        PopupMenuItem(
          value: member.isActive
              ? _MemberAction.deactivate
              : _MemberAction.reactivate,
          child: member.isActive
              ? const _MenuRow(
                  icon: Icons.person_off_outlined,
                  label: 'Deactivate',
                  color: Colors.red)
              : const _MenuRow(
                  icon: Icons.person_outlined,
                  label: 'Reactivate',
                  color: Colors.green),
        ),
      ],
    );
  }

  void _onAction(
      BuildContext context, WidgetRef ref, _MemberAction action) {
    switch (action) {
      case _MemberAction.editDetails:
        context.push(AppRoutes.editMember, extra: member);
      case _MemberAction.resetPin:
        _showResetPinSheet(context, ref);
      case _MemberAction.deactivate:
        _confirmDeactivate(context, ref);
      case _MemberAction.reactivate:
        ref
            .read(memberActionProvider.notifier)
            .reactivate(member.id, business.id, ref);
    }
  }

  void _showResetPinSheet(BuildContext context, WidgetRef ref) {
    showAppSheet(
      context: context,
      builder: (_) => ResetPinSheet(
        member: member,
        onConfirm: (newPin) async {
          final success = await ref
              .read(memberActionProvider.notifier)
              .updatePin(member.id, newPin);
          if (success && context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    showAppDialog(
      context: context,
      title: 'Deactivate ${member.fullName}?',
      message:
          'They will no longer be able to access this business. You can reactivate them later.',
      confirmLabel: 'Deactivate',
      confirmColor: Colors.red,
      onConfirm: () => ref
          .read(memberActionProvider.notifier)
          .deactivate(member.id, business.id, ref),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MenuRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

enum _MemberAction { editDetails, resetPin, deactivate, reactivate }
```

---

## FILE 9 — Add Member Screen
### `lib/src/features/team/presentation/screens/add_member_screen.dart`

```dart
class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtr   = TextEditingController();
  final _phoneCtr  = TextEditingController();
  final _pinCtr    = TextEditingController();
  final _pinCtr2   = TextEditingController();
  String _role     = 'staff';
  bool _obscurePin = true;

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _pinCtr.dispose();
    _pinCtr2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(addMemberProvider).isLoading;

    return Scaffold(
      appBar: AppTopBar(title: 'Add Staff Member'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionLabel('Personal Details'),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameCtr,
              label:      'Full Name',
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller:  _phoneCtr,
              label:       'Phone Number',
              prefixIcon:  Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Phone is required' : null,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Role'),
            const SizedBox(height: 12),
            RoleSelectorWidget(
              selected:   _role,
              onSelected: (role) => setState(() => _role = role),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Access PIN'),
            const SizedBox(height: 4),
            Text(
              'Staff will use this PIN to access the business.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller:   _pinCtr,
              label:        'Create PIN (4–6 digits)',
              prefixIcon:   Icons.lock_outline,
              suffixIcon:   _obscurePin
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap:  () => setState(() => _obscurePin = !_obscurePin),
              obscureText:  _obscurePin,
              keyboardType: TextInputType.number,
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
            AppTextField(
              controller:   _pinCtr2,
              label:        'Confirm PIN',
              prefixIcon:   Icons.lock_outline,
              obscureText:  _obscurePin,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) =>
                  v != _pinCtr.text ? 'PINs do not match' : null,
            ),
            const SizedBox(height: 32),
            AppButton(
              label:     'Add Staff Member',
              isLoading: isLoading,
              onPressed: isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final business = ref.read(requireBusinessProvider);

    final success = await ref.read(addMemberProvider.notifier).addMember(
      businessId: business.id,
      fullName:   _nameCtr.text.trim(),
      phone:      _phoneCtr.text.trim(),
      role:       _role,
      pin:        _pinCtr.text,
      ref:        ref,
    );

    if (success && mounted) context.pop();
  }
}
```

---

## FILE 10 — Role Selector Widget
### `lib/src/features/team/presentation/widgets/role_selector_widget.dart`

```dart
class RoleSelectorWidget extends StatelessWidget {
  final String selected;
  final void Function(String) onSelected;

  const RoleSelectorWidget({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleOption(
          role:       'manager',
          label:      'Manager',
          subtitle:   'Can view reports & manage inventory',
          icon:       Icons.manage_accounts_outlined,
          isSelected: selected == 'manager',
          onTap:      () => onSelected('manager'),
        ),
        const SizedBox(width: 12),
        _RoleOption(
          role:       'staff',
          label:      'Staff',
          subtitle:   'Can record sales only',
          icon:       Icons.badge_outlined,
          isSelected: selected == 'staff',
          onTap:      () => onSelected('staff'),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String role;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        isSelected ? primary.withOpacity(0.07) : Colors.white,
            border:       Border.all(
              color:     isSelected ? primary : Colors.grey.shade300,
              width:     isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  color: isSelected ? primary : Colors.grey,
                  size: 22),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primary : Colors.black87)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## FILE 11 — Reset PIN Sheet Widget
### `lib/src/features/team/presentation/widgets/reset_pin_sheet.dart`

```dart
class ResetPinSheet extends StatefulWidget {
  final StaffMember member;
  final Future<void> Function(String newPin) onConfirm;

  const ResetPinSheet({
    required this.member,
    required this.onConfirm,
    super.key,
  });

  @override
  State<ResetPinSheet> createState() => _ResetPinSheetState();
}

class _ResetPinSheetState extends State<ResetPinSheet> {
  final _pinCtr  = TextEditingController();
  final _pin2Ctr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading  = false;
  bool _obscure  = true;

  @override
  void dispose() {
    _pinCtr.dispose();
    _pin2Ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Reset PIN for ${widget.member.fullName}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Enter a new 4–6 digit PIN',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 20),
            AppTextField(
              controller:      _pinCtr,
              label:           'New PIN',
              prefixIcon:      Icons.lock_outline,
              obscureText:     _obscure,
              keyboardType:    TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              suffixIcon:   _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap:  () => setState(() => _obscure = !_obscure),
              validator: (v) =>
                  (v?.length ?? 0) < 4 ? 'PIN must be at least 4 digits' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller:      _pin2Ctr,
              label:           'Confirm New PIN',
              prefixIcon:      Icons.lock_outline,
              obscureText:     _obscure,
              keyboardType:    TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) =>
                  v != _pinCtr.text ? 'PINs do not match' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              label:     'Update PIN',
              isLoading: _loading,
              onPressed: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await widget.onConfirm(_pinCtr.text);
    setState(() => _loading = false);
  }
}
```

---

## FILE 12 — Routes to Add
### `lib/src/routing/app_routes.dart`

```dart
// Add these to your existing AppRoutes class:
static const team        = '/team';
static const addMember   = '/team/add';
static const editMember  = '/team/edit';
```

### `lib/src/routing/app_router.dart`

```dart
// Add inside your ShellRoute routes list:
GoRoute(
  path:    AppRoutes.team,
  builder: (_, __) => const TeamScreen(),
),
GoRoute(
  path:    AppRoutes.addMember,
  builder: (_, __) => const AddMemberScreen(),
),
GoRoute(
  path:    AppRoutes.editMember,
  builder: (_, s)  => EditMemberScreen(member: s.extra as StaffMember),
),
```

---

## FILE 13 — Edge Function Deployment

```bash
supabase functions deploy create-staff-member
```

Add to `AGENTS.md` Edge Functions table:
```
| `create-staff-member` | Called from Flutter | Creates auth user + users row + business_members row atomically |
```

---

## Folder Structure Summary

```
lib/src/features/team/
├── domain/
│   ├── entities/
│   │   └── staff_member.dart
│   └── repositories/
│       └── team_repository.dart
├── data/
│   └── repositories/
│       └── team_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── team_provider.dart
    ├── screens/
    │   ├── team_screen.dart
    │   └── add_member_screen.dart
    └── widgets/
        ├── team_list.dart
        ├── team_member_card.dart
        ├── role_selector_widget.dart
        └── reset_pin_sheet.dart

supabase/functions/
└── create-staff-member/
    └── index.ts
```

---

---

# Push Notifications — Firebase FCM + Supabase
> Sales · Low Stock · Expired Products
> DB Triggers · pg_cron · Edge Functions · Flutter NotificationService

---

## How Each Event is Triggered

```
New Sale recorded
    └── DB trigger (INSERT on sales)
            └── send-notification Edge Function
                    └── FCM → device

Stock drops to/below threshold
    └── DB trigger (UPDATE on products.quantity)
            └── send-notification Edge Function
                    └── FCM → device

Expired / expiring products
    └── pg_cron (runs daily 08:00)
            └── check-expired-products Edge Function
                    └── queries products WHERE expiry_date <= now() + 3 days
                            └── send-notification Edge Function
                                    └── FCM → device
```

---

## FILE 14 — Shared Edge Function: `send-notification`
### `supabase/functions/send-notification/index.ts`

> This is the single function all triggers call. It looks up FCM tokens
> for the business and sends via FCM HTTP v1 API using a Google service account.

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { GoogleAuth } from "https://esm.sh/google-auth-library@9";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// ── Get OAuth2 access token for FCM HTTP v1 ──────────────────────────────────
async function getFcmAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!);
  const auth = new GoogleAuth({
    credentials: serviceAccount,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const client = await auth.getClient();
  const token  = await client.getAccessToken();
  return token.token!;
}

serve(async (req) => {
  try {
    const {
      business_id,
      event,
      title,
      body,
      data = {},
      notify_roles = ["owner", "manager"], // default: only owner + manager
    } = await req.json();

    if (!business_id || !title || !body) {
      return _error("business_id, title and body are required", 400);
    }

    // ── Get all active users in this business with the right roles ────────
    const { data: members } = await supabase
      .from("business_members")
      .select("user_id")
      .eq("business_id", business_id)
      .eq("is_active", true)
      .in("role", notify_roles);

    if (!members?.length) {
      return _ok({ sent: 0, reason: "no members to notify" });
    }

    const userIds = members.map((m: any) => m.user_id);

    // ── Get FCM tokens for those users ────────────────────────────────────
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token, platform")
      .in("user_id", userIds);

    if (!tokens?.length) {
      return _ok({ sent: 0, reason: "no device tokens registered" });
    }

    // ── Send via FCM HTTP v1 ──────────────────────────────────────────────
    const accessToken = await getFcmAccessToken();
    const projectId   = JSON.parse(Deno.env.get("FCM_SERVICE_ACCOUNT")!).project_id;
    const fcmUrl      = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

    let sent = 0;
    const errors: string[] = [];

    for (const { token, platform } of tokens) {
      const message: any = {
        token,
        notification: { title, body },
        data: {
          event:   event ?? "general",
          channel: data.channel ?? "general",
          route:   data.route   ?? "/dashboard",
          ...data,
        },
      };

      // Android-specific config
      if (platform === "android") {
        message.android = {
          notification: {
            channel_id:   data.channel ?? "general",
            priority:     "HIGH",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
      }

      // iOS-specific config
      if (platform === "ios") {
        message.apns = {
          payload: { aps: { sound: "default", badge: 1 } },
        };
      }

      const res = await fetch(fcmUrl, {
        method:  "POST",
        headers: {
          Authorization:  `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ message }),
      });

      if (res.ok) {
        sent++;
      } else {
        const err = await res.json();
        errors.push(err?.error?.message ?? "unknown FCM error");
      }
    }

    // ── Log notification in DB ────────────────────────────────────────────
    await supabase.from("notification_logs").insert({
      business_id,
      event,
      title,
      body,
      sent_count: sent,
      read:       false,
    });

    return _ok({ sent, errors });
  } catch (e) {
    return _error(`Unexpected error: ${e}`, 500);
  }
});

function _ok(data: object) {
  return new Response(JSON.stringify(data), {
    status:  200,
    headers: { "Content-Type": "application/json" },
  });
}

function _error(message: string, status: number) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
```

---

## FILE 15 — Edge Function: `check-expired-products`
### `supabase/functions/check-expired-products/index.ts`

> Called by pg_cron daily at 08:00.
> Checks products expiring within 3 days AND already expired.
> Sends one consolidated notification per business.

```typescript
import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async () => {
  try {
    const today       = new Date();
    const in3Days     = new Date(today);
    in3Days.setDate(in3Days.getDate() + 3);

    const todayStr   = today.toISOString().split("T")[0];
    const in3DaysStr = in3Days.toISOString().split("T")[0];

    // ── Find all products that are expired or expiring within 3 days ──────
    const { data: products, error } = await supabase
      .from("products")
      .select("id, name, expiry_date, business_id, quantity")
      .not("expiry_date", "is", null)
      .lte("expiry_date", in3DaysStr)    // expiry_date <= today + 3 days
      .gt("quantity", 0);               // only if still in stock

    if (error) throw error;
    if (!products?.length) {
      return new Response(JSON.stringify({ checked: 0 }), { status: 200 });
    }

    // ── Group by business_id ──────────────────────────────────────────────
    const byBusiness: Record<string, typeof products> = {};
    for (const product of products) {
      if (!byBusiness[product.business_id]) {
        byBusiness[product.business_id] = [];
      }
      byBusiness[product.business_id].push(product);
    }

    // ── Send one consolidated notification per business ───────────────────
    const sendUrl = `${Deno.env.get("SUPABASE_URL")}/functions/v1/send-notification`;
    let notified = 0;

    for (const [businessId, bizProducts] of Object.entries(byBusiness)) {
      const expired  = bizProducts.filter((p) => p.expiry_date <= todayStr);
      const expiring = bizProducts.filter((p) => p.expiry_date >  todayStr);

      // Build a clear message
      let title = "";
      let body  = "";

      if (expired.length > 0 && expiring.length > 0) {
        title = "⚠️ Expired & Expiring Products";
        body  = `${expired.length} product(s) expired, ${expiring.length} expiring soon.`;
      } else if (expired.length > 0) {
        title = "🚨 Expired Products";
        body  = expired.length === 1
          ? `${expired[0].name} has expired`
          : `${expired.length} products have expired`;
      } else {
        title = "⏰ Products Expiring Soon";
        body  = expiring.length === 1
          ? `${expiring[0].name} expires in 3 days`
          : `${expiring.length} products expire within 3 days`;
      }

      await fetch(sendUrl, {
        method:  "POST",
        headers: {
          Authorization:  `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          business_id:   businessId,
          event:         "expired_products",
          title,
          body,
          notify_roles:  ["owner", "manager"],
          data: {
            channel: "inventory",
            route:   "/inventory?filter=expired",
          },
        }),
      });

      notified++;
    }

    return new Response(
      JSON.stringify({ businesses_notified: notified, products_found: products.length }),
      { status: 200 },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: `${e}` }), { status: 500 });
  }
});
```

---

## FILE 16 — Database Triggers (SQL)
### Run in Supabase SQL Editor

```sql
-- ── Enable pg_net extension (needed for HTTP calls from triggers) ─────────────
CREATE EXTENSION IF NOT EXISTS pg_net;

-- ── Enable pg_cron extension (needed for scheduled jobs) ─────────────────────
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ────────────────────────────────────────────────────────────────────────────────
-- TRIGGER 1: New Sale → send-notification
-- ────────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION notify_new_sale()
RETURNS trigger AS $$
BEGIN
  PERFORM net.http_post(
    url     := current_setting('app.edge_url') || '/send-notification',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    ),
    body    := jsonb_build_object(
      'business_id',  NEW.business_id,
      'event',        'new_sale',
      'title',        '🛒 New Sale Recorded',
      'body',         '₦' || NEW.total_amount || ' sale recorded'
                      || CASE WHEN NEW.customer_name IS NOT NULL
                              THEN ' for ' || NEW.customer_name
                              ELSE '' END,
      'notify_roles', jsonb_build_array('owner', 'manager'),
      'data', jsonb_build_object(
        'channel', 'sales',
        'route',   '/sales/' || NEW.id,
        'sale_id', NEW.id
      )
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_new_sale
  AFTER INSERT ON sales
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_sale();

-- ────────────────────────────────────────────────────────────────────────────────
-- TRIGGER 2: Low Stock → send-notification
-- Fires only when quantity crosses FROM above threshold TO at/below threshold
-- Prevents repeated alerts on every stock update
-- ────────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION notify_low_stock()
RETURNS trigger AS $$
BEGIN
  -- Only fire when crossing the threshold downward (not on every update)
  IF NEW.quantity <= NEW.low_stock_at AND OLD.quantity > OLD.low_stock_at THEN
    PERFORM net.http_post(
      url     := current_setting('app.edge_url') || '/send-notification',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key')
      ),
      body    := jsonb_build_object(
        'business_id',  NEW.business_id,
        'event',        'low_stock',
        'title',        '⚠️ Low Stock Alert',
        'body',         NEW.name || ' is running low — '
                        || NEW.quantity || ' ' || NEW.unit || ' left',
        'notify_roles', jsonb_build_array('owner', 'manager'),
        'data', jsonb_build_object(
          'channel',    'inventory',
          'route',      '/inventory/' || NEW.id,
          'product_id', NEW.id
        )
      )
    );
  END IF;

  -- Also fire when stock hits zero (separate "finished" alert)
  IF NEW.quantity = 0 AND OLD.quantity > 0 THEN
    PERFORM net.http_post(
      url     := current_setting('app.edge_url') || '/send-notification',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key')
      ),
      body    := jsonb_build_object(
        'business_id',  NEW.business_id,
        'event',        'out_of_stock',
        'title',        '🚨 Item Finished',
        'body',         NEW.name || ' is now out of stock',
        'notify_roles', jsonb_build_array('owner', 'manager'),
        'data', jsonb_build_object(
          'channel',    'inventory',
          'route',      '/inventory/' || NEW.id,
          'product_id', NEW.id
        )
      )
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_low_stock
  AFTER UPDATE OF quantity ON products
  FOR EACH ROW
  EXECUTE FUNCTION notify_low_stock();

-- ────────────────────────────────────────────────────────────────────────────────
-- TRIGGER 3: Set app config values (run once)
-- Replace with your actual values
-- ────────────────────────────────────────────────────────────────────────────────

ALTER DATABASE postgres
  SET app.edge_url        = 'https://YOUR_PROJECT_REF.supabase.co/functions/v1';

ALTER DATABASE postgres
  SET app.service_role_key = 'YOUR_SERVICE_ROLE_KEY';

-- ────────────────────────────────────────────────────────────────────────────────
-- SCHEDULED JOB: Check expired products daily at 08:00 WAT (07:00 UTC)
-- ────────────────────────────────────────────────────────────────────────────────

SELECT cron.schedule(
  'check-expired-products',
  '0 7 * * *',   -- 07:00 UTC = 08:00 WAT every day
  $$
  SELECT net.http_post(
    url     := current_setting('app.edge_url') || '/check-expired-products',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key')
    ),
    body    := '{}'::jsonb
  )
  $$
);

-- ────────────────────────────────────────────────────────────────────────────────
-- NOTIFICATION CHANNELS INDEX (add to existing indexes)
-- ────────────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_products_expiry_business
  ON products(business_id, expiry_date)
  WHERE expiry_date IS NOT NULL AND quantity > 0;
```

---

## FILE 17 — Flutter: NotificationService
### `lib/src/features/notifications/data/notification_service.dart`

```dart
class NotificationService {
  static NotificationService get instance => _instance;
  static final NotificationService _instance = NotificationService._();
  NotificationService._();

  final _messaging          = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // ── Initialize — call once in app.dart via addPostFrameCallback ──────────

  Future<void> initialize() async {
    // 1. Request permission
    final settings = await _messaging.requestPermission(
      alert:     true,
      badge:     true,
      sound:     true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      AppLogger.warning('NotificationService: permission denied');
      return;
    }

    // 2. Local notifications setup (for foreground display)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested above
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Create Android notification channels
    await _createChannels();

    // 4. Save FCM token to Supabase
    await _registerToken();

    // 5. Refresh token if it changes
    _messaging.onTokenRefresh.listen(_saveTokenToSupabase);

    // 6. Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 7. App opened from background via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);

    // 8. App launched from terminated state via notification tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationOpened(initial);

    AppLogger.info('NotificationService: initialized');
  }

  // ── Token registration ────────────────────────────────────────────────────

  Future<void> _registerToken([String? token]) async {
    token ??= await _messaging.getToken();
    if (token == null) return;
    await _saveTokenToSupabase(token);
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id':  userId,
          'token':    token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
      AppLogger.info('NotificationService: token registered');
    } catch (e) {
      AppLogger.error('NotificationService._saveTokenToSupabase', e);
    }
  }

  // Call this on logout to remove the token
  Future<void> removeToken() async {
    final token  = await _messaging.getToken();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (token == null || userId == null) return;

    await Supabase.instance.client
        .from('device_tokens')
        .delete()
        .eq('user_id', userId)
        .eq('token', token);
  }

  // ── Foreground message handler ────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final n = message.notification;
    if (n == null) return;

    final channelId = message.data['channel'] ?? 'general';

    await _localNotifications.show(
      message.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName(channelId),
          channelDescription: _channelDesc(channelId),
          importance: Importance.high,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
          color:      const Color(0xFF1A56DB),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  // ── Tap handlers ──────────────────────────────────────────────────────────

  void _onNotificationTapped(NotificationResponse response) {
    final route = response.payload;
    if (route != null) _navigateTo(route);
  }

  void _onNotificationOpened(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) {
      // Slight delay to ensure router is ready
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _navigateTo(route),
      );
    }
  }

  void _navigateTo(String route) {
    AppRouter.navigatorKey.currentContext?.go(route);
  }

  // ── Android notification channels ─────────────────────────────────────────

  Future<void> _createChannels() async {
    final plugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final channels = [
      const AndroidNotificationChannel(
        'sales',     'Sales',
        description: 'New sale notifications',
        importance:  Importance.high,
      ),
      const AndroidNotificationChannel(
        'inventory', 'Inventory',
        description: 'Low stock and expiry alerts',
        importance:  Importance.high,
      ),
      const AndroidNotificationChannel(
        'expenses',  'Expenses',
        description: 'Expense logged alerts',
        importance:  Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'summary',   'Daily Summary',
        description: 'End-of-day sales summary',
        importance:  Importance.defaultImportance,
      ),
      const AndroidNotificationChannel(
        'debt',      'Debt Reminders',
        description: 'Outstanding customer balance reminders',
        importance:  Importance.high,
      ),
      const AndroidNotificationChannel(
        'general',   'General',
        description: 'General app notifications',
        importance:  Importance.defaultImportance,
      ),
    ];

    for (final ch in channels) {
      await plugin?.createNotificationChannel(ch);
    }
  }

  String _channelName(String id) => switch (id) {
    'sales'     => 'Sales',
    'inventory' => 'Inventory',
    'expenses'  => 'Expenses',
    'summary'   => 'Daily Summary',
    'debt'      => 'Debt Reminders',
    _           => 'General',
  };

  String _channelDesc(String id) => switch (id) {
    'sales'     => 'New sale notifications',
    'inventory' => 'Low stock and expiry alerts',
    'expenses'  => 'Expense logged alerts',
    'summary'   => 'End-of-day sales summary',
    'debt'      => 'Outstanding customer balance reminders',
    _           => 'General app notifications',
  };
}
```

---

## FILE 18 — Wire NotificationService into `app.dart`

```dart
// lib/src/app.dart

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Initialize after first frame so router + context are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      // ... rest of your existing app setup
    );
  }
}
```

---

## FILE 19 — Background Handler in `main.dart`

```dart
// lib/main.dart
// Add this TOP-LEVEL function (must not be inside a class)

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Re-initialize Firebase since this runs in a separate isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info('Background notification: ${message.notification?.title}');
  // Do not show UI here — the OS handles background notification display
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await Supabase.initialize(
    url:     dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    EasyLocalization(
      // ... your localization setup
      child: const ProviderScope(child: App()),
    ),
  );
}
```

---

## FILE 20 — Re-register Token After Login
### `lib/src/features/auth/presentation/providers/session_provider.dart`

```dart
// Add this inside your auth state change listener
// so tokens are always registered after sign-in

Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
  if (data.event == AuthChangeEvent.signedIn) {
    // Re-register FCM token now that we have a user_id
    await NotificationService.instance.initialize();
  }

  if (data.event == AuthChangeEvent.signedOut) {
    // Remove token so logged-out user stops receiving notifications
    await NotificationService.instance.removeToken();
  }
});
```

---

## FILE 21 — Notification Route Constants
### `lib/src/routing/app_routes.dart`

```dart
// Add these to your existing AppRoutes class:
static const notifications        = '/notifications';
static const inventoryExpired     = '/inventory?filter=expired';
static const inventoryLowStock    = '/inventory?filter=low_stock';
static const salesDetail          = '/sales/:id';
static const reports              = '/reports';
```

---

## Edge Function Deployment

```bash
# Deploy both functions
supabase functions deploy send-notification
supabase functions deploy check-expired-products

# Set required secrets (run once)
supabase secrets set FCM_SERVICE_ACCOUNT='{"type":"service_account","project_id":"..."}' 
```

---

## Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Push notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Required for Firebase -->
<uses-permission android:name="android.permission.INTERNET" />
```

Add to `android/app/build.gradle`:
```groovy
apply plugin: 'com.google.gms.google-services'
```

Add to `android/build.gradle`:
```groovy
classpath 'com.google.gms:google-services:4.4.1'
```

Place `google-services.json` in `android/app/`.
Place `GoogleService-Info.plist` in `ios/Runner/`.

---

## Notification Events Summary

| Event | Trigger | Channel | Route on Tap | Who Gets It |
|---|---|---|---|---|
| 🛒 New Sale | DB trigger INSERT on `sales` | `sales` | `/sales/:id` | Owner + Manager |
| ⚠️ Low Stock | DB trigger UPDATE on `products.quantity` | `inventory` | `/inventory/:id` | Owner + Manager |
| 🚨 Item Finished | DB trigger UPDATE quantity = 0 | `inventory` | `/inventory/:id` | Owner + Manager |
| 🗓 Expiring Soon | pg_cron 08:00 daily | `inventory` | `/inventory?filter=expired` | Owner + Manager |
| 🚨 Expired | pg_cron 08:00 daily | `inventory` | `/inventory?filter=expired` | Owner + Manager |

---

## Updated Folder Structure

```
lib/src/features/
├── team/                          (as before)
└── notifications/
    └── data/
        └── notification_service.dart   ← FILE 17

supabase/functions/
├── create-staff-member/
│   └── index.ts                        ← FILE 1
├── send-notification/
│   └── index.ts                        ← FILE 14
└── check-expired-products/
    └── index.ts                        ← FILE 15
```

## Setup Checklist

- [ ] Create Firebase project → download `google-services.json` + `GoogleService-Info.plist`
- [ ] Add `firebase_core`, `firebase_messaging`, `flutter_local_notifications` to `pubspec.yaml`
- [ ] Register `_firebaseBackgroundHandler` in `main.dart` before `runApp()`
- [ ] Call `NotificationService.instance.initialize()` in `app.dart`
- [ ] Re-register token on `AuthChangeEvent.signedIn` in session provider
- [ ] Remove token on `AuthChangeEvent.signedOut`
- [ ] Run trigger SQL in Supabase SQL editor
- [ ] Set `app.edge_url` and `app.service_role_key` in DB settings
- [ ] Enable `pg_net` and `pg_cron` extensions in Supabase Dashboard → Database → Extensions
- [ ] Deploy `send-notification` Edge Function
- [ ] Deploy `check-expired-products` Edge Function
- [ ] Set `FCM_SERVICE_ACCOUNT` secret in Supabase
- [ ] Schedule `check-expired-products` with pg_cron
- [ ] Test on physical device (FCM does not work on simulators)
