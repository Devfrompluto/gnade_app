import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_summary_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_products_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_totals_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_details_bottom_bar.dart';

class SaleDetailsScreen extends StatelessWidget {
  final String id;

  const SaleDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Mock data derived from id for testing UI logic
    final String paymentStatus;
    final double amountPaid;
    const double total = 105887.50;
    
    // Generate a status deterministically based on the length of the string
    // Or just simple condition to show the different states.
    if (id.isEmpty || id.length % 3 == 0) {
      paymentStatus = 'Paid';
      amountPaid = total;
    } else if (id.length % 3 == 1) {
      paymentStatus = 'Unpaid';
      amountPaid = 0.0;
    } else {
      paymentStatus = 'Partial';
      amountPaid = 50000.0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slight gray background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSurface,
            size: 24.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Sale details',
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  children: [
                    SaleSummaryCard(paymentStatus: paymentStatus),
                    SizedBox(height: 12.h),
                    const SaleProductsCard(),
                    SizedBox(height: 12.h),
                    SaleTotalsCard(
                      paymentStatus: paymentStatus,
                      total: total,
                      amountPaid: amountPaid,
                    ),
                    SizedBox(height: 24.h), // Extra padding before bottom bar
                  ],
                ),
              ),
            ),
            SaleDetailsBottomBar(paymentStatus: paymentStatus),
          ],
        ),
      ),
    );
  }
}
