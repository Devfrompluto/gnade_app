import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_summary_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_products_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_totals_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_payment_history_card.dart';
import 'package:gnade_app/src/features/sales/presentation/widgets/sale_details_bottom_bar.dart';
import '../widgets/share_receipt_options_sheet.dart';
import '../providers/sales_providers.dart';

class SaleDetailsScreen extends ConsumerWidget {
  final String id;

  const SaleDetailsScreen({super.key, required this.id});

  ReceiptData _buildReceiptData(WidgetRef ref, Sale sale) {
    final businessProfile = ref.read(businessProfileProvider).value;
    final String bName = businessProfile?.name ?? 'Kinetic Retail';
    final String bAddress = businessProfile?.address ?? '';
    final String bPhone = businessProfile?.phone ?? '';

    final receiptItems = (sale.items ?? <SaleItem>[]).map((item) {
      return ReceiptItem(
        name: item.productName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total,
      );
    }).toList();

    final calculatedSubtotal = receiptItems.fold<double>(0, (sum, item) => sum + item.total);
    final calculatedTax = sale.totalAmount - (calculatedSubtotal - sale.discount);

    final rawStatus = sale.status.toLowerCase();
    final String paymentStatus = rawStatus == 'paid'
        ? 'Paid'
        : (rawStatus == 'refunded' ? 'Refunded' : 'Partial');

    String displayPaymentMethod = sale.paymentMethod;
    if (displayPaymentMethod.toLowerCase() == 'cash') {
      displayPaymentMethod = 'Cash';
    } else if (displayPaymentMethod.toLowerCase() == 'bank' || displayPaymentMethod.toLowerCase() == 'transfer') {
      displayPaymentMethod = 'Bank Transfer';
    } else if (displayPaymentMethod.toLowerCase() == 'mobile') {
      displayPaymentMethod = 'Mobile Payment';
    } else if (displayPaymentMethod.toLowerCase() == 'credit') {
      displayPaymentMethod = 'Credit / Debt';
    }

    return ReceiptData(
      businessName: bName,
      businessAddress: bAddress,
      businessPhone: bPhone,
      businessEmail: '',
      businessLogoUrl: businessProfile?.logoUrl,
      invoiceNo: sale.invoiceNo,
      dateTime: sale.createdAt,
      customerName: sale.customerName,
      customerType: sale.customerName == 'Retail Customer' ? 'Regular Customer' : 'Retail Customer',
      items: receiptItems,
      subtotal: calculatedSubtotal,
      tax: calculatedTax > 0.01 ? calculatedTax : 0.0,
      total: sale.totalAmount,
      amountPaid: sale.amountPaid,
      paymentMethod: displayPaymentMethod,
      paymentStatus: paymentStatus,
    );
  }

  void _openShareOptions(BuildContext context, WidgetRef ref, Sale sale) {
    final receiptData = _buildReceiptData(ref, sale);
    showShareReceiptSheet(context, receiptData);
  }

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
        actions: [
          saleDetailsAsync.maybeWhen(
            data: (sale) => IconButton(
              icon: Icon(
                Icons.share_rounded,
                color: const Color(0xFF2563EB),
                size: 22.sp,
              ),
              tooltip: 'Share Receipt',
              onPressed: () => _openShareOptions(context, ref, sale),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          SizedBox(width: 6.w),
        ],
      ),
      body: SafeArea(
        child: saleDetailsAsync.when(
          data: (sale) {
            final rawStatus = sale.status.toLowerCase();
            final paymentStatus = rawStatus == 'paid' 
                ? 'Paid' 
                : (rawStatus == 'refunded'
                    ? 'Returned'
                    : (rawStatus == 'partial_refund'
                        ? 'P. Returned'
                        : (rawStatus == 'partial' ? 'Partial' : 'Unpaid')));

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
                        SizedBox(height: 12.h),
                        SalePaymentHistoryCard(sale: sale),
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
