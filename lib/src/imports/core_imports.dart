// Flutter SDK
export 'package:flutter/material.dart';
export 'package:flutter/cupertino.dart' hide RefreshCallback;
export 'package:flutter/foundation.dart';
export 'package:flutter/services.dart';
export 'package:flutter_native_splash/flutter_native_splash.dart';

export 'package:easy_localization/easy_localization.dart' hide TextDirection, MapExtension;

// Project Core — everything exported through shared.dart (theme, extensions,
// utils, widgets, enums) plus routing and services.
export '../config/app_config.dart';
export '../routing/app_router.dart';
export '../routing/app_routes.dart';
export '../routing/global_navigator.dart';
export '../services/services.dart';
export '../shared/shared.dart';

export '../features/auth/presentation/screens/login_screen.dart';
export '../features/auth/presentation/screens/signup_screen.dart';
export '../features/auth/presentation/screens/forgot_password_screen.dart';
export '../features/home/presentation/screens/dashboard_screen.dart';
export '../features/home/presentation/screens/more_screen.dart';
export '../features/home/presentation/screens/app_settings_screen.dart';
export '../features/home/presentation/screens/business_settings_screen.dart';
export '../features/notifications/presentation/screens/notifications_screen.dart';
export '../features/onboarding/presentation/screens/onboarding_page.dart';
export '../features/sales/presentation/screens/sales_screen.dart';
export '../features/sales/presentation/screens/select_item_screen.dart';
export '../features/sales/presentation/screens/new_sale_screen.dart';
export '../features/inventory/presentation/screens/products_screen.dart';
export '../features/inventory/presentation/screens/product_details_screen.dart';
export '../features/inventory/presentation/screens/supplier_details_screen.dart';
export '../features/inventory/presentation/screens/purchase_details_screen.dart';
export '../features/customers/presentation/screens/customers_screen.dart';
export '../features/customers/presentation/screens/customer_details_screen.dart';
export '../features/printing/domain/entities/receipt_data.dart';
export '../features/printing/presentation/screens/receipt_preview_screen.dart';
export '../features/printing/presentation/widgets/widgets.dart';
