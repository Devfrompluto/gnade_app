import 'package:gnade_app/src/imports/core_imports.dart';

import 'package:gnade_app/src/features/notifications/data/notification_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _buildMaterialApp(context);
    return ScreenUtilWrapper(child: current);
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp.router(
      title: 'gnade_app',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#1A56DB'),
      darkTheme: buildDarkTheme(primaryColorHex: '#1A56DB'),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        
        // Globally dismiss keyboard on tap outside input fields
        current = GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: current,
        );
        
        return current;
      },
    );
  }
}