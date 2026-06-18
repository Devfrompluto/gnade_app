import 'package:gnade_app/src/imports/imports.dart';

class SoldProductsSection extends StatelessWidget {
  const SoldProductsSection({super.key});

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
                        'Sales amount(₦)',
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
              _buildSoldRow(
                name: 'Nirvana Bottled water',
                qty: '4.0',
                amount: '6,000',
                textTheme: textTheme,
              ),
              const Divider(),
              _buildSoldRow(
                name: 'Goldberg Bottle',
                qty: '2.0',
                amount: '18,200',
                textTheme: textTheme,
              ),
              const Divider(),
              _buildSoldRow(
                name: 'Heineken 45cl (medium)',
                qty: '2.0',
                amount: '34,400',
                textTheme: textTheme,
              ),
              const Divider(),
              _buildSoldRow(
                name: 'Legend Bottle',
                qty: '1.0',
                amount: '11,800',
                textTheme: textTheme,
              ),
            ],
          ),
        ),

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
