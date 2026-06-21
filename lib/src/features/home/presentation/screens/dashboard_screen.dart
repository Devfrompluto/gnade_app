import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../widgets/home_menu_section.dart';
import '../widgets/sold_products_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showSalesBalance = true;
  bool _showExpensesBalance = true;
  int _selectedTabIndex = 0; // 0: Home menu, 1: Sold products

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very light gray background
      appBar: const AppMainHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding.w,
                vertical: AppSpacing.md.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 2. METRICS CARDS SECTION (Sales & Expenses)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10.w,
                    children: [
                      AppMetricCard(
                        title: 'Today Sales',
                        value: '₦ 145,200',
                        isGreen: true,
                        showValue: _showSalesBalance,
                        onToggleVisibility: () {
                          setState(() {
                            _showSalesBalance = !_showSalesBalance;
                          });
                        },
                      ),
                      AppMetricCard(
                        title: 'Today Expenses',
                        value: '₦ 12,500',
                        isGreen: false,
                        showValue: _showExpensesBalance,
                        isIncreasing: false,
                        onToggleVisibility: () {
                          setState(() {
                            _showExpensesBalance = !_showExpensesBalance;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md.h),

                // 3. SEGMENTED TAB SELECTOR (Home menu / Sold products)
                Container(
                  height: 40.h,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFE2E8F0), // Light slate container background
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      // Home menu tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                'Home menu',
                                style: TextStyle(
                                  color: _selectedTabIndex == 0
                                      ? Colors.white
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sold products tab
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 1),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.r),
                              border: _selectedTabIndex == 1
                                  ? Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Sold products',
                                style: TextStyle(
                                  color: _selectedTabIndex == 1
                                      ? colorScheme.primary
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacing.md.h),

                // 4. TAB CONTENTS
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedTabIndex == 0
                      ? const HomeMenuSection()
                      : const SoldProductsSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
