import 'package:gnade_app/src/utils/utils.dart';
import '../entities/dashboard_data.dart';

abstract class HomeRepository {
  FutureEither<DashboardData> getDashboardData(String businessId);
}
