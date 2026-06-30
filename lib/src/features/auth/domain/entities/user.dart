import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? businessId;
  final String? role; // owner | manager | staff

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.businessId,
    this.role,
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  /// Whether the user has completed business initialization.
  bool get isInitialized => businessId != null && businessId!.isNotEmpty;

  @override
  List<Object?> get props => [id, email, name, photoUrl, businessId, role];
}
