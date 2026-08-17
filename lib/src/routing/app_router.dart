import 'package:go_router/go_router.dart';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/features/sales/presentation/screens/sale_success_screen.dart';
import 'package:gnade_app/src/features/sales/presentation/screens/sale_details_screen.dart';
import 'package:gnade_app/src/features/customers/presentation/screens/select_customer_screen.dart';
import 'package:gnade_app/src/features/customers/presentation/screens/add_customer_screen.dart';
import '../features/products/presentation/screens/add_product_screen.dart';
import '../features/products/presentation/screens/edit_product_screen.dart';
import '../features/products/presentation/screens/add_stock_screen.dart';
import 'package:gnade_app/src/features/team/presentation/screens/team_screen.dart';
import 'package:gnade_app/src/features/team/presentation/screens/add_member_screen.dart';
import 'package:gnade_app/src/features/team/presentation/screens/edit_member_screen.dart';
import 'package:gnade_app/src/features/team/domain/entities/staff_member.dart';
import 'package:gnade_app/src/features/auth/presentation/screens/employee_login_screen.dart';
import 'package:gnade_app/src/features/printing/presentation/screens/saved_printers_screen.dart';
import 'package:gnade_app/src/features/printing/presentation/screens/add_printer_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: (StorageService.instance.getBool('has_seen_onboarding') ?? false)
      ? AppRoutes.login
      : AppRoutes.onboarding,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.employeeLogin,
      name: 'employeeLogin',
      builder: (context, state) => const EmployeeLoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectBusiness,
      name: 'selectBusiness',
      builder: (context, state) => const SelectBusinessScreen(),
    ),
    GoRoute(
      path: AppRoutes.createBusiness,
      name: 'createBusiness',
      builder: (context, state) => const CreateBusinessScreen(),
    ),
    GoRoute(
      path: AppRoutes.createPin,
      name: 'createPin',
      builder: (context, state) {
        final details = state.extra as Map<String, dynamic>;
        return CreatePinScreen(businessDetails: details);
      },
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.printReceipt,
      name: 'printReceipt',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final receiptData = state.extra as ReceiptData?;
        return ReceiptPreviewScreen(receiptData: receiptData);
      },
    ),
    
    // Stateful Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.sales,
              name: 'sales',
              builder: (context, state) => const SalesScreen(),
              routes: [
                GoRoute(
                  path: 'select-item',
                  name: 'selectItem',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const SelectItemScreen(),
                ),
                GoRoute(
                  path: 'new',
                  name: 'newSale',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    final selectedItems = extra?['products'] as List<ProductItemMock>?;
                    final quantities = extra?['quantities'] as Map<String, int>?;
                    final defaultPriceType = extra?['priceType'] as String? ?? 'wholesale';
                    return NewSaleScreen(
                      selectedItems: selectedItems ?? const [],
                      initialQuantities: quantities ?? const {},
                      defaultPriceType: defaultPriceType,
                    );
                  },
                ),
                GoRoute(
                  path: 'success',
                  name: 'saleSuccess',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    return SaleSuccessScreen(
                      invoiceNo: extra['invoiceNo'] as String,
                      amountPaid: extra['amountPaid'] as double,
                      paymentMethod: extra['paymentMethod'] as String,
                      paymentStatus: extra['paymentStatus'] as String? ?? 'Paid',
                      total: extra['total'] as double? ?? extra['amountPaid'] as double,
                      dateTime: extra['dateTime'] as DateTime,
                      receiptData: extra['receiptData'] as ReceiptData?,
                    );
                  },
                ),
                GoRoute(
                  path: 'details/:id',
                  name: 'saleDetails',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return SaleDetailsScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'select-customer',
                  name: 'selectCustomer',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const SelectCustomerScreen(),
                ),
                GoRoute(
                  path: 'add-customer',
                  name: 'addCustomer',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const AddCustomerScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.products,
              name: 'products',
              builder: (context, state) => const ProductsScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'addProduct',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const AddProductScreen(),
                ),
                GoRoute(
                  path: 'edit',
                  name: 'editProduct',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return EditProductScreen(product: product);
                  },
                ),
                GoRoute(
                  path: 'details/:id',
                  name: 'productDetails',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return ProductDetailsScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'supplier/:id',
                  name: 'supplierDetails',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return SupplierDetailsScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'purchase/:id',
                  name: 'purchaseDetails',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return PurchaseDetailsScreen(id: id);
                  },
                ),
                GoRoute(
                  path: 'add-stock',
                  name: 'addStock',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final product = state.extra as Product;
                    return AddStockScreen(product: product);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.customers,
              name: 'customers',
              builder: (context, state) => const CustomersScreen(),
              routes: [
                GoRoute(
                  path: 'details/:id',
                  name: 'customerDetails',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return CustomerDetailsScreen(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              name: 'more',
              builder: (context, state) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'app-settings',
                  name: 'appSettings',
                  builder: (context, state) => const AppSettingsScreen(),
                ),
                GoRoute(
                  path: 'business-settings',
                  name: 'businessSettings',
                  builder: (context, state) => const BusinessSettingsScreen(),
                ),
                GoRoute(
                  path: 'team',
                  name: 'team',
                  builder: (context, state) => const TeamScreen(),
                  routes: [
                    GoRoute(
                      path: 'add',
                      name: 'addMember',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const AddMemberScreen(),
                    ),
                    GoRoute(
                      path: 'edit',
                      name: 'editMember',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => EditMemberScreen(
                        member: state.extra as StaffMember,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'saved-printers',
                  name: 'savedPrinters',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const SavedPrintersScreen(),
                ),
                GoRoute(
                  path: 'add-printer',
                  name: 'addPrinter',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const AddPrinterScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.suppliers,
      name: 'suppliers',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SuppliersScreen(),
    ),
    GoRoute(
      path: AppRoutes.addSupplier,
      name: 'addSupplier',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddSupplierScreen(),
    ),
  ],
);
