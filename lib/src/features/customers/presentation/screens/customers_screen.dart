import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';
import '../widgets/customer_horizontal_metrics.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(filteredCustomersProvider);
    final allCustomers = ref.watch(customerListProvider);
    final activeFilter = ref.watch(customerFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // light slate gray background
      appBar: const AppMainHeader(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addCustomer),
        backgroundColor: const Color(0xFF1E3A8A), // Deep blue/navy FAB
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22.sp),
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: TextField(
              onChanged: (val) => ref.read(customerSearchQueryProvider.notifier).state = val,
              onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              style: TextStyle(
                fontSize: 14.sp, 
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                ),
              ),
            ),
          ),

          // 2. Metrics cards list
          CustomerHorizontalMetrics(customers: allCustomers),
          SizedBox(height: 16.h),

          // 3. Filter pills row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                _buildFilterPill(ref, CustomerFilterType.all, 'All', activeFilter),
                SizedBox(width: 8.w),
                _buildFilterPill(ref, CustomerFilterType.debtors, 'Debtors', activeFilter),
                SizedBox(width: 8.w),
                _buildFilterPill(ref, CustomerFilterType.depositers, 'Depositers', activeFilter),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 4. Scrollable List of Customers
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Text(
                      'No customers found.',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 80.h),
                    children: [
                      ...customers.map((c) => _buildCustomerTile(context, c)),
                      SizedBox(height: 16.h),
                      Center(
                        child: TextButton(
                          onPressed: () => showGlobalToast(message: 'Loading more...'),
                          child: Text(
                            'Load More Customers',
                            style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w900,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    WidgetRef ref,
    CustomerFilterType filter,
    String label,
    CustomerFilterType activeFilter,
  ) {
    final isActive = filter == activeFilter;

    return GestureDetector(
      onTap: () => ref.read(customerFilterProvider.notifier).state = filter,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive ? Colors.transparent : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTile(BuildContext context, CustomerMock c) {
    final hasDebt = c.balance < 0;
    final hasDeposit = c.balance > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            context.pushNamed(
              'customerDetails',
              pathParameters: {'id': c.id},
            );
          },
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        leading: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: c.initialsColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              c.initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
        title: Text(
          c.name,
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 13.sp,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            'Last seen: ${c.lastSeen}',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDebt)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-₦${NumberFormat('#,###').format(c.balance.abs())}',
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    'Owed',
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else if (hasDeposit)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+₦${NumberFormat('#,###').format(c.balance)}',
                    style: TextStyle(
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    'Deposit',
                    style: TextStyle(
                      color: const Color(0xFF059669),
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    ),);
  }
}
