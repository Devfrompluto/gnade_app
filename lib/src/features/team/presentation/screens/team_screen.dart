import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../../domain/entities/staff_member.dart';
import '../providers/team_provider.dart';
import '../widgets/team_list.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch<SessionState>(sessionProvider);
    final user = sessionState.user;
    final businessId = user?.businessId ?? '';
    final role = user?.role ?? 'staff';
    
    // Both owner and manager roles can manage team members
    final canManage = role == 'owner' || role == 'manager';
    final teamAsync = ref.watch<AsyncValue<List<StaffMember>>>(teamMembersProvider(businessId));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Using page-bg from design: #F3F4F6
      appBar: const AppTopBar(title: 'Team'),
      body: teamAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(teamMembersProvider(businessId)),
        ),
        data: (members) => members.isEmpty
            ? AppEmptyState(
                icon: Icons.people_outline,
                title: 'No team members yet',
                subtitle: 'Add staff members to manage access',
                actionLabel: canManage ? 'Add Staff Member' : null,
                onAction: canManage
                    ? () => context.push(AppRoutes.addMember)
                    : null,
              )
            : TeamList(members: members, canManage: canManage),
      ),
    );
  }
}
