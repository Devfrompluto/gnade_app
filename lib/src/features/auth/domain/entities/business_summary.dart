import 'package:equatable/equatable.dart';

class BusinessSummary extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? logoUrl;
  final String currency;
  final String role;
  final bool hasPin;

  const BusinessSummary({
    required this.id,
    required this.name,
    this.category,
    this.logoUrl,
    required this.currency,
    required this.role,
    required this.hasPin,
  });

  factory BusinessSummary.fromMap(Map<String, dynamic> map) {
    return BusinessSummary(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      logoUrl: map['logo_url'] as String?,
      currency: map['currency'] as String? ?? 'NGN',
      role: map['role'] as String? ?? 'owner',
      hasPin: map['has_pin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'logo_url': logoUrl,
      'currency': currency,
      'role': role,
      'has_pin': hasPin,
    };
  }

  @override
  List<Object?> get props => [id, name, category, logoUrl, currency, role, hasPin];
}
