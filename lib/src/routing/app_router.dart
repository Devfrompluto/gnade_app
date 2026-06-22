import 'package:go_router/go_router.dart';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/product_item_tile.dart';
import 'package:gnade_app/src/features/sales/presentation/screens/sale_success_screen.dart';
import 'package:gnade_app/src/features/sales/presentation/screens/sale_details_screen.dart';
import 'package:gnade_app/src/features/customers/presentation/screens/select_customer_screen.dart';
import 'package:gnade_app/src/features/customers/presentation/screens/add_customer_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
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
                    return NewSaleScreen(
                      selectedItems: selectedItems ?? const [],
                      initialQuantities: quantities ?? const {},
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
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              name: 'more',
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
