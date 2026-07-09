import 'package:equatable/equatable.dart';

class BusinessProfile extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String currency;

  const BusinessProfile({
    required this.id,
    required this.name,
    this.category,
    this.phone,
    this.address,
    this.logoUrl,
    required this.currency,
  });

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {
    return BusinessProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      logoUrl: map['logo_url'] as String?,
      currency: map['currency'] as String? ?? 'NGN',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'phone': phone,
      'address': address,
      'logo_url': logoUrl,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [id, name, category, phone, address, logoUrl, currency];
}
