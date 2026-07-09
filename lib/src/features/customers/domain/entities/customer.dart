import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerOrder extends Equatable {
  final String id;
  final String invoiceNo;
  final String status; // 'PAID' or 'UNPAID'
  final DateTime date;
  final int itemsCount;
  final double amount;

  const CustomerOrder({
    required this.id,
    required this.invoiceNo,
    required this.status,
    required this.date,
    required this.itemsCount,
    required this.amount,
  });

  @override
  List<Object?> get props => [id, invoiceNo, status, date, itemsCount, amount];
}

class Customer extends Equatable {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? notes;
  final double totalOwed;
  final double depositAmount;
  final List<CustomerOrder> orders;

  const Customer({
    required this.id,
    required this.businessId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.notes,
    required this.totalOwed,
    required this.depositAmount,
    this.orders = const [],
  });

  String get initials {
    if (name.isEmpty) return '';
    return name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
  }

  Color get initialsColor {
    final colors = [
      const Color(0xFF1E3A8A), // Deep Slate/Navy
      const Color(0xFF10B981), // Emerald
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF0D9488), // Teal
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  // Compatibility getters
  double get balance => depositAmount - totalOwed;
  int get purchasesCount => orders.length;
  String get lastSeen {
    if (orders.isEmpty) return 'Never';
    final latestDate = orders.map((o) => o.date).reduce((a, b) => a.isAfter(b) ? a : b);
    final now = DateTime.now();
    final difference = now.difference(latestDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(latestDate);
    }
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        phone,
        email,
        address,
        notes,
        totalOwed,
        depositAmount,
        orders,
      ];
}

typedef CustomerMock = Customer;
typedef CustomerOrderMock = CustomerOrder;
