import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';

class CustomerTabsView extends StatefulWidget {
  final CustomerMock customer;

  const CustomerTabsView({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerTabsView> createState() => _CustomerTabsViewState();
}

class _CustomerTabsViewState extends State<CustomerTabsView> {
  int _activeTab = 0; // 0: History, 1: Debt, 2: Notes

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Modern Pill-Shaped Segmented Tab Bar
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9), // slate-100
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Row(
            children: [
              _buildTabHeader(0, 'History'),
              _buildTabHeader(1, 'Debt'),
              _buildTabHeader(2, 'Notes'),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Tab Content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildActiveTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabHeader(int index, String label) {
    final isActive = _activeTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildHistoryTab();
      case 1:
        return _buildDebtTab();
      case 2:
        return _buildNotesTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildHistoryTab() {
    final orders = widget.customer.orders;

    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_rounded, size: 48.sp, color: const Color(0xFFCBD5E1)),
            SizedBox(height: 16.h),
            Text(
              'No purchase history found.',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: orders.map((order) {
        final isPaid = order.status == 'PAID';

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isPaid ? Icons.shopping_bag_rounded : Icons.money_off_rounded,
                    color: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.id,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: isPaid ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w900,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${order.itemsCount} ${order.itemsCount == 1 ? 'item' : 'items'} • ${order.date}',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '₦${order.amount}',
                style: TextStyle(
                  color: isPaid ? const Color(0xFF0F172A) : const Color(0xFFDC2626),
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDebtTab() {
    final debtOrders = widget.customer.orders.where((o) => o.status == 'UNPAID').toList();

    if (debtOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 48.sp, color: const Color(0xFF10B981)),
            SizedBox(height: 16.h),
            Text(
              'No outstanding debts.',
              style: TextStyle(
                color: const Color(0xFF059669),
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2), // soft red
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Outstanding Debt',
                style: TextStyle(
                  color: const Color(0xFF991B1B),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '₦${NumberFormat('#,###').format(widget.customer.balance.abs())}',
                style: TextStyle(
                  color: const Color(0xFFDC2626),
                  fontWeight: FontWeight.w900,
                  fontSize: 24.sp,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ...debtOrders.map((order) {
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.money_off_rounded, color: const Color(0xFFDC2626), size: 20.sp),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        order.date,
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₦${order.amount}',
                  style: TextStyle(
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w900,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesTab() {
    final noteText = widget.customer.notes ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: const Color(0xFF94A3B8), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Customer Notes',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            noteText.isEmpty ? 'No notes recorded for this customer.' : noteText,
            style: TextStyle(
              color: const Color(0xFF475569),
              fontSize: 14.sp,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
