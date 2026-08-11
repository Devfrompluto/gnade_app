import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String phone;
  final double supplyValue;
  final double debtAmount;
  final String? category;
  final String? contactPerson;
  final String? email;
  final String? creditTerms;
  final String? notes;
  final DateTime? createdAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.supplyValue = 0.0,
    this.debtAmount = 0.0,
    this.category,
    this.contactPerson,
    this.email,
    this.creditTerms,
    this.notes,
    this.createdAt,
  });

  bool get hasDebt => debtAmount > 0;

  String get initial {
    if (name.isEmpty) return 'S';
    return name.trim()[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        supplyValue,
        debtAmount,
        category,
        contactPerson,
        email,
        creditTerms,
        notes,
        createdAt,
      ];
}
