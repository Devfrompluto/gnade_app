import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/home/domain/entities/dashboard_data.dart';

class SoldProductsSection extends StatelessWidget {
  final List<SoldProductItem> items;
  const SoldProductsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Column(
      key: const ValueKey('sold_products_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table Title
        Text(
          'List of products sold today',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: 14.sp,
          ),
        ),

        SizedBox(height: AppSpacing.md.h),

        if (items.isEmpty) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const AppEmptyState(
              icon: Icons.shopping_basket_outlined,
              title: 'No sales today',
              subtitle: 'Any products sold today will show up here.',
            ),
          ),
        ] else ...[
          // Sold Products Table Container
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Products',
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Qty sold',
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Sales amount',
                          textAlign: TextAlign.center,
                          style: textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Table Rows
                ...items.map((item) {
                  final isLast = items.indexOf(item) == items.length - 1;
                  return Column(
                    children: [
                      _buildSoldRow(
                        name: item.productName,
                        qty: item.quantitySold.toString(),
                        amount: NumberFormat('#,##0').format(item.salesAmount),
                        textTheme: textTheme,
                      ),
                      if (!isLast) const Divider(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],

        SizedBox(height: AppSpacing.xxl.h),
      ],
    );
  }

  // Row helper for Sold Products Table
  Widget _buildSoldRow({
    required String name,
    required String qty,
    required String amount,
    required TextTheme textTheme,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Name
          Expanded(
            flex: 4,
            child: Text(
              name,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
                fontSize: 14.sp,
              ),
            ),
          ),

          // Quantity (Centered, Green)
          Expanded(
            flex: 2,
            child: Text(
              qty,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16A34A),
                fontSize: 14.sp,
              ),
            ),
          ),

          // Amount (Centered, Blue)
          Expanded(
            flex: 2,
            child: Text(
              amount,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A56DB),
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
