import 'package:gnade_app/src/imports/imports.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/team_repository.dart';
import '../../data/repositories/team_repository_impl.dart';

final teamRepositoryProvider = Provider<TeamRepository>(
  (_) => TeamRepositoryImpl(),
);

final teamMembersProvider =
    FutureProvider.family<List<StaffMember>, String>((ref, businessId) async {
  final result =
      await ref.read(teamRepositoryProvider).getTeamMembers(businessId);
  return result.fold(
    (failure) => throw failure,
    (members) => members,
  );
});

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
    required String email,
    required String employeeId,
    required String role,
    required String pin,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repo.addStaffMember(
      businessId: businessId,
      fullName:   fullName,
      phone:      phone,
      email:      email,
      employeeId: employeeId,
      role:       role,
      pin:        pin,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        showGlobalToast(message: failure.message, status: 'error');
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(teamMembersProvider(businessId));
        showGlobalToast(message: 'Staff member added successfully', status: 'success');
        return true;
      },
    );
  }
}

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

  Future<bool> updateMember({
    required String memberId,
    required String fullName,
    required String phone,
    required String role,
    required String businessId,
    required WidgetRef ref,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repo.updateStaffMember(
      memberId: memberId,
      fullName: fullName,
      phone: phone,
      role: role,
    );
    return result.fold(
      (f) {
        state = AsyncValue.error(f, StackTrace.current);
        showGlobalToast(message: f.message, status: 'error');
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(teamMembersProvider(businessId));
        showGlobalToast(message: 'Staff member details updated', status: 'success');
        return true;
      },
    );
  }

  Future<bool> updatePin(String memberId, String newPin) async {
    state = const AsyncValue.loading();
    final result = await _repo.updatePin(memberId: memberId, newPin: newPin);
    return result.fold(
      (f) {
        state = AsyncValue.error(f, StackTrace.current);
        showGlobalToast(message: f.message, status: 'error');
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        showGlobalToast(message: 'PIN updated', status: 'success');
        return true;
      },
    );
  }

  Future<bool> _run(
    FutureEither<void> Function() action,
    String businessId,
    WidgetRef ref,
    String successMessage,
  ) async {
    state = const AsyncValue.loading();
    final result = await action();
    return result.fold(
      (f) {
        state = AsyncValue.error(f, StackTrace.current);
        showGlobalToast(message: f.message, status: 'error');
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        ref.invalidate(teamMembersProvider(businessId));
        showGlobalToast(message: successMessage, status: 'success');
        return true;
      },
    );
  }
}
