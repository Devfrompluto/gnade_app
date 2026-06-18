import 'package:gnade_app/src/imports/imports.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Products'),
      body: Center(
        child: Text(
          'Products inventory screen coming soon!',
          style: context.theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
