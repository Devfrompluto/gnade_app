import 'package:gnade_app/src/imports/imports.dart';

class HomeMenuSection extends StatelessWidget {
  const HomeMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.theme.textTheme;
    final colorScheme = context.theme.colorScheme;

    return Column(
      key: const ValueKey('home_menu_view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 3x3 Grid of Menu Cards
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.85,
          children: [
            AppGridMenuCard(
              icon: Icons.point_of_sale_rounded,
              label: 'New sale',
              iconColor: const Color(0xFF1A56DB),
              badgeColor: const Color(0xFFEBF2FF),
              onTap: () => showToast(context,
                  message: 'New Sale POS tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.inventory_2_outlined,
              label: 'Products',
              iconColor: const Color(0xFF7C3AED),
              badgeColor: const Color(0xFFF3E8FF),
              onTap: () => showToast(context,
                  message: 'Products inventory tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.swap_horiz_rounded,
              label: 'Cash flow',
              iconColor: const Color(0xFF0F8546),
              badgeColor: const Color(0xFFE8F6EE),
              onTap: () => showToast(context,
                  message: 'Cash Flow tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.receipt_long_rounded,
              label: 'Expenses',
              iconColor: const Color(0xFFD32F2F),
              badgeColor: const Color(0xFFFBECEB),
              onTap: () => showToast(context,
                  message: 'Expenses log tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.trending_down_rounded,
              label: 'Debts',
              iconColor: const Color(0xFFD97706),
              badgeColor: const Color(0xFFFEF3C7),
              onTap: () => showToast(context,
                  message: 'Debts management tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.shopping_cart_outlined,
              label: 'Purchases',
              iconColor: const Color(0xFF0D9488),
              badgeColor: const Color(0xFFE6FDF9),
              onTap: () => showToast(context,
                  message: 'Purchases tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.bar_chart_rounded,
              label: 'Reports',
              iconColor: const Color(0xFF2563EB),
              badgeColor: const Color(0xFFEFF6FF),
              onTap: () => showToast(context,
                  message: 'Reports analytics tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.description_outlined,
              label: 'Invoice',
              iconColor: const Color(0xFF475569),
              badgeColor: const Color(0xFFF1F5F9),
              onTap: () => showToast(context,
                  message: 'Invoice history tapped', status: 'info'),
            ),
            AppGridMenuCard(
              icon: Icons.local_shipping_outlined,
              label: 'Suppliers',
              iconColor: const Color(0xFF1E3A8A),
              badgeColor: const Color(0xFFDBEAFE),
              onTap: () => showToast(context,
                  message: 'Suppliers directory tapped', status: 'info'),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.md.h),

        // Quick Actions Section Header
        Text(
          'Quick Actions',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: 16.sp,
          ),
        ),

        SizedBox(height: AppSpacing.md.h),

        // List Tiles
        AppQuickActionTile(
          icon: Icons.sticky_note_2_outlined,
          label: 'View and add notes',
          iconColor: const Color(0xFF2563EB),
          badgeColor: const Color(0xFFEFF6FF),
          onTap: () => showToast(context,
              message: 'View and Add Notes tapped', status: 'info'),
        ),
        AppQuickActionTile(
          icon: Icons.receipt_long_rounded,
          label: 'Add Expense',
          iconColor: const Color(0xFFD32F2F),
          badgeColor: const Color(0xFFFBECEB),
          onTap: () =>
              showToast(context, message: 'Add Expense tapped', status: 'info'),
        ),
        AppQuickActionTile(
          icon: Icons.payment_rounded,
          label: 'Record debt payment',
          iconColor: const Color(0xFF0F8546),
          badgeColor: const Color(0xFFE8F6EE),
          onTap: () => showToast(context,
              message: 'Record Debt Payment tapped', status: 'info'),
        ),
        SizedBox(height: AppSpacing.lg.h),
      ],
    );
  }
}
