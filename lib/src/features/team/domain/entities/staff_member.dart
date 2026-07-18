import 'package:equatable/equatable.dart';

class StaffMember extends Equatable {
  final String id;           // business_members.id
  final String userId;       // users.id
  final String fullName;
  final String phone;
  final String email;        // internal email for auth
  final String role;         // 'owner' | 'manager' | 'staff'
  final String? employeeId;  // null for owner
  final bool isActive;
  final DateTime createdAt;

  const StaffMember({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email = '',
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

  factory StaffMember.fromMap(Map<String, dynamic> row) {
    final user = row['users'] as Map<String, dynamic>?;
    return StaffMember(
      id:         row['id'] as String,
      userId:     row['user_id'] as String,
      fullName:   user?['full_name'] as String? ?? '',
      phone:      user?['phone'] as String? ?? '',
      email:      '',
      role:       row['role'] as String,
      employeeId: row['employee_id'] as String?,
      isActive:   row['is_active'] as bool? ?? true,
      createdAt:  DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, userId, fullName, phone, email, role, employeeId, isActive, createdAt];
}
