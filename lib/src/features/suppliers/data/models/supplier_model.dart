import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id,
    required super.name,
    required super.phone,
    super.supplyValue,
    super.debtAmount,
    super.category,
    super.contactPerson,
    super.email,
    super.creditTerms,
    super.notes,
    super.createdAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      supplyValue: double.tryParse(map['supply_value']?.toString() ?? '') ?? 0.0,
      debtAmount: double.tryParse(map['debt_amount']?.toString() ?? '') ?? 0.0,
      category: map['category']?.toString(),
      contactPerson: map['contact_person']?.toString(),
      email: map['email']?.toString(),
      creditTerms: map['credit_terms']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'supply_value': supplyValue,
      'debt_amount': debtAmount,
      if (category != null) 'category': category,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (email != null) 'email': email,
      if (creditTerms != null) 'credit_terms': creditTerms,
      if (notes != null) 'notes': notes,
    };
  }
}
