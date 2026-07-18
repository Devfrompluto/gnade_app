import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/team_repository.dart';

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

        return data.map((row) => StaffMember.fromMap(row)).toList();
      });

  // ── Add staff member via Edge Function ───────────────────────────────

  @override
  FutureEither<StaffMember> addStaffMember({
    required String businessId,
    required String fullName,
    required String phone,
    required String email,
    required String employeeId,
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
            'email':       email.trim(),
            if (employeeId.trim().isNotEmpty) 'employee_id': employeeId.trim(),
            'role':        role,
            'pin':         pin,
          },
        );

        if (response.status != 200) {
          final message = (response.data as Map?)?['error'] ?? 'Failed to add staff';
          throw ServerFailure(message as String);
        }

        final returnedEmployeeId = response.data['employee_id'] as String;
        final userId     = response.data['user_id'] as String;

        return StaffMember(
          id:         '',
          userId:     userId,
          fullName:   fullName.trim(),
          phone:      phone.trim(),
          email:      email.trim(),
          role:       role,
          employeeId: returnedEmployeeId,
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
        await _client
            .from('business_members')
            .update({'role': role})
            .eq('id', memberId);

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

  // ── Deactivate ───────────────────────────────────────────────────────

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
