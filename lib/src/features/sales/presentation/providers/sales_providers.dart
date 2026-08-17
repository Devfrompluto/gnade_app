import 'package:gnade_app/src/imports/imports.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/repositories/sales_repository_impl.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(Supabase.instance.client);
});

// Selected Date Filter: 0: Today, 1: Yesterday, 2: Last 7 Days, 3: This Month, 4: Custom
final salesDateFilterProvider = StateProvider<int>((ref) => 0);

// Custom Date Range Provider (for Custom Date Filter option)
final salesCustomDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Selected Cashier Filter Provider ('All' or specific cashier name)
final selectedCashierFilterProvider = StateProvider<String>((ref) => 'All');

// Helpers to get start and end dates based on current filter index
Map<String, DateTime> resolveSalesDateRange(int filterIndex, DateTimeRange? customRange) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day, 0, 0, 0);
  final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

  if (filterIndex == 4 && customRange != null) {
    return {
      'start': DateTime(customRange.start.year, customRange.start.month, customRange.start.day, 0, 0, 0),
      'end': DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59),
    };
  }

  switch (filterIndex) {
    case 0: // Today
      return {'start': todayStart, 'end': todayEnd};
    case 1: // Yesterday
      final y = now.subtract(const Duration(days: 1));
      return {
        'start': DateTime(y.year, y.month, y.day, 0, 0, 0),
        'end': DateTime(y.year, y.month, y.day, 23, 59, 59),
      };
    case 2: // Last 7 Days
      final start = now.subtract(const Duration(days: 7));
      return {
        'start': DateTime(start.year, start.month, start.day, 0, 0, 0),
        'end': todayEnd,
      };
    case 3: // This Month
      final monthStart = DateTime(now.year, now.month, 1, 0, 0, 0);
      final nextMonthFirst = (now.month == 12)
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);
      final monthEnd = nextMonthFirst.subtract(const Duration(seconds: 1));
      return {
        'start': monthStart,
        'end': monthEnd,
      };
    default:
      return {'start': todayStart, 'end': todayEnd};
  }
}

// FutureProvider for Sales Summary Metrics
final salesSummaryProvider = FutureProvider<SalesSummary>((ref) async {
  final repo = ref.watch(salesRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  
  if (businessId == null) {
    return const SalesSummary(count: 0, totalAmount: 0, grossProfit: 0);
  }

  final filterIndex = ref.watch(salesDateFilterProvider);
  final customRange = ref.watch(salesCustomDateRangeProvider);
  final range = resolveSalesDateRange(filterIndex, customRange);

  final result = await repo.getSalesSummary(
    businessId: businessId,
    startDate: range['start']!,
    endDate: range['end']!,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (summary) => summary,
  );
});

// FutureProvider for Sales History List
final salesHistoryProvider = FutureProvider.family<List<Sale>, String?>((ref, status) async {
  final repo = ref.watch(salesRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  
  if (businessId == null) return [];

  final filterIndex = ref.watch(salesDateFilterProvider);
  final customRange = ref.watch(salesCustomDateRangeProvider);
  final range = resolveSalesDateRange(filterIndex, customRange);

  final result = await repo.getSales(
    businessId: businessId,
    startDate: range['start']!,
    endDate: range['end']!,
    status: status,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (sales) => sales,
  );
});

// FutureProvider for individual sale details
final saleDetailsProvider = FutureProvider.family<Sale, String>((ref, saleId) async {
  final repo = ref.watch(salesRepositoryProvider);
  final result = await repo.getSaleDetails(saleId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sale) => sale,
  );
});

// Checkout state controller (to manage loading and saving transactions)
class SalesCheckoutNotifier extends StateNotifier<AsyncValue<Sale?>> {
  final SalesRepository _repository;
  final String? _businessId;
  final AppUser? _user;

  SalesCheckoutNotifier(this._repository, this._businessId, this._user)
      : super(const AsyncValue.data(null));

  Future<Sale?> recordSale({
    required String customerName,
    required double totalAmount,
    required double amountPaid,
    required double discount,
    required String paymentMethod,
    required String status,
    required String invoiceNo,
    required List<Map<String, dynamic>> items,
    String? cashierName,
  }) async {
    if (_businessId == null) {
      state = AsyncValue.error(Exception('No active business ID found'), StackTrace.current);
      return null;
    }

    final String resolvedCashier = cashierName ??
        ((_user?.name != null && _user!.name!.trim().isNotEmpty)
            ? _user.name!.trim()
            : (_user?.role != null && _user!.role!.trim().isNotEmpty
                ? _user.role![0].toUpperCase() + _user.role!.substring(1).toLowerCase()
                : 'Staff'));

    state = const AsyncValue.loading();
    final result = await _repository.createSale(
      businessId: _businessId,
      customerName: customerName,
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      discount: discount,
      paymentMethod: paymentMethod,
      status: status,
      invoiceNo: invoiceNo,
      items: items,
      cashierName: resolvedCashier,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
        return null;
      },
      (sale) {
        state = AsyncValue.data(sale);
        return sale;
      },
    );
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final salesCheckoutProvider = StateNotifierProvider<SalesCheckoutNotifier, AsyncValue<Sale?>>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final businessId = session.user?.businessId;
  final user = session.user;
  return SalesCheckoutNotifier(repo, businessId, user);
});
