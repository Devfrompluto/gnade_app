import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/team_provider.dart';
import 'reset_pin_sheet.dart';

enum _MemberAction { editDetails, resetPin, deactivate, reactivate }

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
    final sessionState = ref.read<SessionState>(sessionProvider);
    final businessId = sessionState.user?.businessId ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: _MemberAvatar(
              name: member.fullName,
              role: member.role,
              isActive: member.isActive),
          title: Text(
            member.fullName.trim().isNotEmpty ? member.fullName : 'New Member',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF141C2B), // on-background
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                member.role == 'owner'
                    ? 'Admin'
                    : member.role == 'manager'
                        ? 'Store Manager'
                        : 'Sales Rep',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF434654), // on-surface-variant
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    member.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5E6572), // on-secondary-container
                    ),
                  ),
                  if (member.employeeId != null)
                    Text(
                      '•  ${member.employeeId!}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5E6572),
                        fontFamily: 'monospace',
                      ),
                    ),
                ],
              ),
              if (!member.isActive) ...[
                const SizedBox(height: 4),
                const Text(
                  'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFE02424), // danger-red
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          trailing: canManage && !member.isOwner
              ? _MemberMenu(member: member, businessId: businessId, ref: ref)
              : null,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  final String name;
  final String role;
  final bool isActive;

  const _MemberAvatar({
    required this.name,
    required this.role,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Avatar background and text color switch based on Stitch specs
    final (Color bg, Color textColor) = switch (role.toLowerCase()) {
      'owner' => (const Color(0xFF1E3A5F), Colors.white), // avatar-navy
      'manager' => (const Color(0xFF6B21A8), Colors.white), // avatar-purple
      _ => name.hashCode.isEven
          ? (const Color(0xFF0F766E), Colors.white) // avatar-teal
          : (
              const Color(0xFFDCE2F3),
              const Color(0xFF5E6572)
            ), // secondary-container / on-secondary-container
    };

    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberMenu extends ConsumerWidget {
  final StaffMember member;
  final String businessId;
  final WidgetRef ref;

  const _MemberMenu({
    required this.member,
    required this.businessId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF434654)),
      onPressed: () => _showOptionsSheet(context, ref),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    showAppSheet<void>(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Member Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF141C2B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading:
                      const Icon(Icons.edit_outlined, color: Color(0xFF141C2B)),
                  title: const Text(
                    'Edit details',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141C2B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onAction(context, ref, _MemberAction.editDetails);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined,
                      color: Color(0xFF141C2B)),
                  title: const Text(
                    'Reset PIN',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF141C2B),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onAction(context, ref, _MemberAction.resetPin);
                  },
                ),
                ListTile(
                  leading: Icon(
                    member.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_outlined,
                    color: member.isActive
                        ? const Color(0xFFE02424)
                        : const Color(0xFF0E9F6E),
                  ),
                  title: Text(
                    member.isActive
                        ? 'Deactivate account'
                        : 'Reactivate account',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: member.isActive
                          ? const Color(0xFFE02424)
                          : const Color(0xFF0E9F6E),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onAction(
                        context,
                        ref,
                        member.isActive
                            ? _MemberAction.deactivate
                            : _MemberAction.reactivate);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onAction(BuildContext context, WidgetRef ref, _MemberAction action) {
    switch (action) {
      case _MemberAction.editDetails:
        context.push(AppRoutes.editMember, extra: member);
        break;
      case _MemberAction.resetPin:
        _showResetPinSheet(context, ref);
        break;
      case _MemberAction.deactivate:
        _confirmDeactivate(context, ref);
        break;
      case _MemberAction.reactivate:
        ref
            .read<MemberActionNotifier>(memberActionProvider.notifier)
            .reactivate(member.id, businessId, ref);
        break;
    }
  }

  void _showResetPinSheet(BuildContext context, WidgetRef ref) {
    showAppSheet<void>(
      child: ResetPinSheet(
        member: member,
        onConfirm: (newPin) async {
          final success = await ref
              .read<MemberActionNotifier>(memberActionProvider.notifier)
              .updatePin(member.id, newPin);
          if (success && context.mounted) Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    showAppDialog<void>(
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deactivate ${member.fullName}?',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF141C2B)),
              ),
              const SizedBox(height: 12),
              Text(
                'They will no longer be able to access this business. You can reactivate them later.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      ref
                          .read<MemberActionNotifier>(
                              memberActionProvider.notifier)
                          .deactivate(member.id, businessId, ref);
                      Navigator.pop(context);
                    },
                    child: const Text('Deactivate',
                        style: TextStyle(color: Color(0xFFE02424))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
        Icon(icon, size: 16, color: color ?? const Color(0xFF141C2B)),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color ?? const Color(0xFF141C2B))),
      ],
    );
  }
}
