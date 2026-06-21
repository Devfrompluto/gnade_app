import 'package:gnade_app/src/imports/imports.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppMainHeader(),
      body: Center(
        child: Text(
          'Customers debt management screen coming soon!',
          style: context.theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
