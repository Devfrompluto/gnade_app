import 'package:flutter/material.dart';

class CustomerMock {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final Color initialsColor;

  const CustomerMock({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    required this.initialsColor,
  });

  // Helper to extract the first letter of name
  String get initials {
    if (name.isEmpty) return '';
    return name.trim().substring(0, 1).toUpperCase();
  }
}
