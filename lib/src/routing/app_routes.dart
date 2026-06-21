/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.onboarding)` instead of `context.go('/')`.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Shell Tabs
  static const String dashboard = '/dashboard';
  static const String sales = '/sales';
  static const String products = '/products';
  static const String customers = '/customers';
  static const String more = '/more';

  // Sales Inner Flow
  static const String selectItem = '/sales/select-item';
  static const String newSale = '/sales/new';
  static const String saleSuccess = '/sales/success';
  static const String selectCustomer = '/sales/select-customer';
  static const String addCustomer = '/sales/add-customer';
  static const String printReceipt = '/print-receipt';
}
