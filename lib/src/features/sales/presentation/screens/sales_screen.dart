import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../widgets/sales_metric_card.dart';
import '../widgets/sale_card.dart';
import '../providers/sales_providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSalesAmount = true;
  bool _showGrossProfit = true;
  bool _isCashierFiltered = false;

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

  Future<void> _handleRefresh() async {
    if (!await requireConnectivity()) return;
    ref.invalidate(salesSummaryProvider);
    ref.invalidate(salesHistoryProvider(null));
    await ref.read(salesSummaryProvider.future);
    await ref.read(salesHistoryProvider(null).future);
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(salesCustomDateRangeProvider.notifier).state = picked;
      ref.read(salesDateFilterProvider.notifier).state = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedDateFilter = ref.watch(salesDateFilterProvider);
    final salesSummaryAsync = ref.watch(salesSummaryProvider);
    final salesHistoryAsync = ref.watch(salesHistoryProvider(null));

    final isRefreshing = salesSummaryAsync.isRefreshing || salesHistoryAsync.isRefreshing;
    final isLoading = salesSummaryAsync.isLoading || salesHistoryAsync.isLoading || isRefreshing;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppMainHeader(),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF1E40AF),
          child: Column(
            children: [
              // ─── Main Content (Scrollable) ──────────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                          _buildDateFilters(selectedDateFilter),
                          SizedBox(height: 16.h),

                          // Metrics Carousel
                          _buildMetricsCarousel(salesSummaryAsync),
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
                          _buildSalesList(salesHistoryAsync, isLoading),
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
      ),
    );
  }

  Widget _buildDateFilters(int selectedDateFilter) {
    final filters = ['Today', 'Yesterday', 'Last 7 Days', 'Custom'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = selectedDateFilter == index;
          final isCustom = index == 3;

          return GestureDetector(
            onTap: () {
              if (isCustom) {
                _selectCustomDateRange();
              } else {
                ref.read(salesDateFilterProvider.notifier).state = index;
              }
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

  Widget _buildMetricsCarousel(AsyncValue<SalesSummary> asyncSummary) {
    return Skeletonizer(
      enabled: asyncSummary.isLoading,
      child: SizedBox(
        height: 76.h,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
          children: [
            SalesMetricCard(
              title: 'Sales count',
              value: asyncSummary.maybeWhen(
                data: (s) => s.count.toString(),
                orElse: () => '0',
              ),
              bg: const Color(0xFFEFF6FF),
              border: const Color(0xFFDBEAFE),
              textColor: const Color(0xFF1E40AF),
              showToggle: false,
            ),
            SizedBox(width: 10.w),

            SalesMetricCard(
              title: 'Sales amount',
              value: asyncSummary.maybeWhen(
                data: (s) => '₦ ${NumberFormat('#,##0').format(s.totalAmount)}',
                orElse: () => '₦ 0',
              ),
              bg: const Color(0xFFECFDF5),
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

            SalesMetricCard(
              title: 'Gross profit',
              value: asyncSummary.maybeWhen(
                data: (s) => '₦ ${NumberFormat('#,##0').format(s.grossProfit)}',
                orElse: () => '₦ 0',
              ),
              bg: const Color(0xFFFAF5FF),
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
      ),
    );
  }

  Widget _buildCashierFilterChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
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
            'Cashier: Staff',
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

  Widget _buildSalesList(AsyncValue<List<Sale>> asyncSales, bool isLoading) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final tabIndex = _tabController.index;

        return asyncSales.when(
          data: (sales) {
            final filteredSales = sales.where((sale) {
              if (tabIndex == 1) return sale.isPaid;
              if (tabIndex == 2) return !sale.isPaid;
              return true;
            }).toList();

            if (filteredSales.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: 60.h),
                child: const Center(
                  child: AppEmptyState(
                    title: 'No sales found',
                    subtitle: 'Sales recorded in the selected period will appear here.',
                  ),
                ),
              );
            }

            return Skeletonizer(
              enabled: isLoading,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
                itemCount: filteredSales.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final sale = filteredSales[index];
                  return SaleCard(sale: sale);
                },
              ),
            );
          },
          loading: () => Skeletonizer(
            enabled: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                return SaleCard(
                  sale: Sale(
                    id: 'placeholder',
                    businessId: 'placeholder',
                    customerName: 'Customer Name',
                    totalAmount: 10000,
                    amountPaid: 10000,
                    discount: 0,
                    paymentMethod: 'CASH',
                    status: 'paid',
                    invoiceNo: '#BZ00000000',
                    createdAt: DateTime.now(),
                  ),
                );
              },
            ),
          ),
          error: (error, _) => Padding(
            padding: EdgeInsets.all(24.w),
            child: Center(
              child: Text(
                'Error loading sales: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
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
                  context.push(AppRoutes.dashboard);
                },
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
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
                    color: const Color(0xFF1E40AF),
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
