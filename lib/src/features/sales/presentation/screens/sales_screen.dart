import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../widgets/sales_metric_card.dart';
import '../widgets/sale_card.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDateFilter = 0; // 0: Today, 1: Yesterday, 2: Last 7 Days, 3: Custom
  bool _showSalesAmount = true;
  bool _showGrossProfit = true;
  bool _isCashierFiltered = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppMainHeader(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── Main Content (Scrollable) ──────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: 90.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        // Title "Sales"
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                          child: Text(
                            'Sales',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                              fontSize: 26.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Date filter pills
                        _buildDateFilters(),
                        SizedBox(height: 16.h),

                        // Metrics Carousel (Scrollable cards)
                        _buildMetricsCarousel(),
                        SizedBox(height: 14.h),

                        // Cashier Filter Tag
                        if (_isCashierFiltered)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                            child: _buildCashierFilterChip(),
                          ),
                        if (_isCashierFiltered) SizedBox(height: 14.h),

                        // TabBar for All / Paid / Unpaid
                        _buildTabBar(),
                        SizedBox(height: 12.h),

                        // Sales Cards List
                        _buildSalesList(),
                      ],
                    ),
                  ),

                  // ─── Bottom Actions Row ────────────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomActions(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    final filters = ['Today', 'Yesterday', 'Last 7 Days', 'Custom'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedDateFilter == index;
          final isCustom = index == 3;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateFilter = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (isCustom) ...[
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14.sp,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF334155),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricsCarousel() {
    return SizedBox(
      height: 76.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
        children: [
          // Card 1: Sales count
          const SalesMetricCard(
            title: 'Sales count',
            value: '124',
            bg: Color(0xFFEFF6FF), // soft blue
            border: Color(0xFFDBEAFE),
            textColor: Color(0xFF1E40AF),
            showToggle: false,
          ),
          SizedBox(width: 10.w),

          // Card 2: Sales amount
          SalesMetricCard(
            title: 'Sales amount',
            value: '₦ 11,500',
            bg: const Color(0xFFECFDF5), // soft green
            border: const Color(0xFFD1FAE5),
            textColor: const Color(0xFF065F46),
            showToggle: true,
            isToggled: _showSalesAmount,
            onToggle: () {
              setState(() {
                _showSalesAmount = !_showSalesAmount;
              });
            },
          ),
          SizedBox(width: 10.w),

          // Card 3: Gross profit
          SalesMetricCard(
            title: 'Gross profit',
            value: '₦ 7,300',
            bg: const Color(0xFFFAF5FF), // soft purple
            border: const Color(0xFFF3E8FF),
            textColor: const Color(0xFF6B21A8),
            showToggle: true,
            isToggled: _showGrossProfit,
            onToggle: () {
              setState(() {
                _showGrossProfit = !_showGrossProfit;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCashierFilterChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // light gray slate
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 14.sp,
            color: const Color(0xFF64748B),
          ),
          SizedBox(width: 4.w),
          Text(
            'Cashier: gnade',
            style: TextStyle(
              color: const Color(0xFF475569),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _isCashierFiltered = false;
              });
            },
            child: Icon(
              Icons.close_rounded,
              size: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF1E40AF),
        unselectedLabelColor: const Color(0xFF64748B),
        indicatorColor: const Color(0xFF1E40AF),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All sales'),
          Tab(text: 'Paid'),
          Tab(text: 'Unpaid'),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final tabIndex = _tabController.index;
        
        final sales = [
          SaleMock(
            invoice: '#BZ01109328',
            paymentMethod: 'CASH',
            isPaid: true,
            time: '12:45 PM',
            cashier: 'gnade',
            amount: '₦ 11,500',
            customer: 'None',
            date: 'Jun 13, 2026 17:19',
          ),
          SaleMock(
            invoice: '#BZ01109327',
            paymentMethod: 'CARD',
            isPaid: true,
            time: '12:30 PM',
            cashier: 'gnade',
            amount: '₦ 4,200',
            customer: 'Christ',
            date: 'Jun 13, 2026 16:29',
          ),
          SaleMock(
            invoice: '#BZ01109326',
            paymentMethod: 'TRANSFER',
            isPaid: false,
            time: '11:15 AM',
            cashier: 'gnade',
            amount: '₦ 2,500',
            customer: 'Aunty Grace',
            date: 'Jun 13, 2026 15:09',
          ),
        ];

        final filteredSales = sales.where((sale) {
          if (tabIndex == 1) return sale.isPaid;
          if (tabIndex == 2) return !sale.isPaid;
          return true;
        }).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
          itemCount: filteredSales.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final sale = filteredSales[index];
            return SaleCard(sale: sale);
          },
        );
      },
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Statistics Button
            Expanded(
              flex: 4,
              child: GestureDetector(
                onTap: () {
                  // Navigate to statistics or show dialog
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Emerald Green
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Statistics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // Record a Sale Button
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: () {
                  context.push(AppRoutes.selectItem);
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF), // Deep Blue
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Record a sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
