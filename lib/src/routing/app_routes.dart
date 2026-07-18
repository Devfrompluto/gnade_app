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
  static const String employeeLogin = '/employee-login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String selectBusiness = '/select-business';
  static const String createBusiness = '/create-business';
  static const String createPin = '/create-pin';

  // Shell Tabs
  static const String dashboard = '/dashboard';
  static const String sales = '/sales';
  static const String products = '/products';
  static const String customers = '/customers';
  static const String more = '/more';
  static const String appSettings = '/more/app-settings';
  static const String businessSettings = '/more/business-settings';
  static const String team = '/more/team';
  static const String addMember = '/more/team/add';
  static const String editMember = '/more/team/edit';
  static const String notifications = '/notifications';

  // Sales Inner Flow
  static const String selectItem = '/sales/select-item';
  static const String newSale = '/sales/new';
  static const String saleDetails = '/sales/details';
  static const String saleSuccess = '/sales/success';
  static const String selectCustomer = '/sales/select-customer';
  static const String addCustomer = '/sales/add-customer';
  static const String printReceipt = '/print-receipt';
  static const String addProduct = '/products/add';
  static const String editProduct = '/products/edit';
  static const String productDetails = '/products/details';
  static const String supplierDetails = '/products/supplier';
  static const String purchaseDetails = '/products/purchase';
  static const String customerDetails = '/customers/details';
}


