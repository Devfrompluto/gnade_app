import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_summary_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_products_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_totals_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_details_bottom_bar.dart';
import '../providers/sales_providers.dart';

class SaleDetailsScreen extends ConsumerWidget {
  final String id;

  const SaleDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final saleDetailsAsync = ref.watch(saleDetailsProvider(id));

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
        child: saleDetailsAsync.when(
          data: (sale) {
            // Capitalize status string for legacy widget compatibility
            final rawStatus = sale.status.toLowerCase();
            final paymentStatus = rawStatus == 'paid' 
                ? 'Paid' 
                : (rawStatus == 'partial' ? 'Partial' : 'Unpaid');

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      children: [
                        SaleSummaryCard(sale: sale),
                        SizedBox(height: 12.h),
                        SaleProductsCard(
                          items: sale.items ?? const [],
                          discount: sale.discount,
                          totalAmount: sale.totalAmount,
                        ),
                        SizedBox(height: 12.h),
                        SaleTotalsCard(
                          paymentStatus: paymentStatus,
                          total: sale.totalAmount,
                          amountPaid: sale.amountPaid,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                SaleDetailsBottomBar(sale: sale),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF1E40AF),
            ),
          ),
          error: (error, _) => Padding(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Text(
                'Error loading sale details: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
