import 'package:flutter/material.dart';

class CustomerOrderMock {
  final String id;
  final String status; // 'PAID' or 'UNPAID'
  final String date;
  final int itemsCount;
  final String amount;

  const CustomerOrderMock({
    required this.id,
    required this.status,
    required this.date,
    required this.itemsCount,
    required this.amount,
  });
}

class CustomerMock {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final Color initialsColor;
  final int purchasesCount;
  final double balance; // Negative for Owed, Positive for Deposit, 0 for None
  final String lastSeen;
  final List<CustomerOrderMock> orders;

  const CustomerMock({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    required this.initialsColor,
    this.purchasesCount = 0,
    this.balance = 0,
    this.lastSeen = 'Never',
    this.orders = const [],
  });

  // Helper to extract the first letter of name
  String get initials {
    if (name.isEmpty) return '';
    return name.trim().substring(0, 1).toUpperCase();
  }
}
