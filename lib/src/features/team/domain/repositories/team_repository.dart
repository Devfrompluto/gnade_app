import 'package:gnade_app/src/imports/core_imports.dart';
import '../entities/staff_member.dart';

abstract class TeamRepository {
  FutureEither<List<StaffMember>> getTeamMembers(String businessId);

  FutureEither<StaffMember> addStaffMember({
    required String businessId,
    required String fullName,
    required String phone,
    required String email,
    required String employeeId,
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
