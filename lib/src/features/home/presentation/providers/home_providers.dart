import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/home/domain/entities/dashboard_data.dart';
import 'package:gnade_app/src/features/home/domain/repositories/home_repository.dart';
import 'package:gnade_app/src/features/home/data/repositories/home_repository_impl.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(Supabase.instance.client);
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final sessionState = ref.watch(sessionProvider);
  final businessId = sessionState.user?.businessId;

  if (businessId == null || businessId.isEmpty) {
    return const DashboardData(
      todaySales: 0,
      todayExpenses: 0,
      soldProducts: [],
    );
  }

  final repo = ref.read(homeRepositoryProvider);
  final result = await repo.getDashboardData(businessId);

  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});
