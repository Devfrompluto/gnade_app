import 'package:equatable/equatable.dart';

class SoldProductItem extends Equatable {
  final String productName;
  final double quantitySold;
  final double salesAmount;

  const SoldProductItem({
    required this.productName,
    required this.quantitySold,
    required this.salesAmount,
  });

  @override
  List<Object?> get props => [productName, quantitySold, salesAmount];
}

class DashboardData extends Equatable {
  final double todaySales;
  final double todayExpenses;
  final List<SoldProductItem> soldProducts;

  const DashboardData({
    required this.todaySales,
    required this.todayExpenses,
    required this.soldProducts,
  });

  @override
  List<Object?> get props => [todaySales, todayExpenses, soldProducts];
}
