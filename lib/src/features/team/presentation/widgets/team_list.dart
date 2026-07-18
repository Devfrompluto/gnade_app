import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/team_provider.dart';
import 'team_member_card.dart';

class TeamList extends StatelessWidget {
  final List<StaffMember> members;
  final bool canManage;

  const TeamList({
    super.key,
    required this.members,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    final active = members.where((m) => m.isActive).toList();
    final inactive = members.where((m) => !m.isActive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        final container = ProviderScope.containerOf(context);
        final sessionState = container.read<SessionState>(sessionProvider);
        final businessId = sessionState.user?.businessId ?? '';
        container.invalidate(teamMembersProvider(businessId));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team List',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF141C2B), // on-background
                ),
              ),
              if (canManage)
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.addMember),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text(
                    'Add Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB), // primary-container
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    elevation: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Active members section
          ...active.map(
            (m) => TeamMemberCard(member: m, canManage: canManage),
          ),

          // Inactive members section
          if (inactive.isNotEmpty && canManage) ...[
            const SizedBox(height: 24),
            Text(
              'Inactive Members',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF434654),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            ...inactive.map(
              (m) => TeamMemberCard(member: m, canManage: canManage),
            ),
          ],

          // Descriptive context box at the bottom
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3FF), // surface-container-low
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF737686).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Text(
              'Manage your shop team members here. You can edit permissions, reset security PINs, or deactivate accounts for former employees.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Color(0xFF434654), // on-surface-variant
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
