import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.businessId,
    required super.name,
    required super.phone,
    super.email,
    super.address,
    super.notes,
    required super.totalOwed,
    required super.depositAmount,
    super.orders = const [],
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toString() ?? '',
      businessId: map['business_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString(),
      address: map['address']?.toString(),
      notes: map['notes']?.toString(),
      totalOwed: double.tryParse(map['total_owed']?.toString() ?? '') ?? 0.0,
      depositAmount: double.tryParse(map['deposit_amount']?.toString() ?? '') ?? 0.0,
      orders: const [], // Will be loaded dynamically if needed
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'total_owed': totalOwed,
      'deposit_amount': depositAmount,
    };
  }
}
