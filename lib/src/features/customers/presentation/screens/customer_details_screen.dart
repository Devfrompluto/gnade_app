import 'dart:ui';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/customer_providers.dart';
import '../widgets/customer_profile_header.dart';
import '../widgets/customer_tabs_view.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final String id;

  const CustomerDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerListProvider);
    final customer = customers.firstWhere(
      (c) => c.id == id,
      orElse: () => customers.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // light slate gray background
      appBar: AppCustomAppBar(
        title: customer.name,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF0F172A), size: 20.sp),
            onPressed: () => showGlobalToast(message: 'Customer options coming soon'),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              border: const Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: SafeArea(
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => showGlobalToast(message: 'Record Payment coming soon'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669), // emerald-600
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment_rounded, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Record Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // 1. Premium Profile Avatar Header Card Component
            CustomerProfileHeader(customer: customer),
            SizedBox(height: 24.h),

            // 2. Modern Tabs Selector (History / Debt / Notes) Component
            CustomerTabsView(customer: customer),
            SizedBox(height: 40.h), // Extra padding for bottom bar
          ],
        ),
      ),
    );
  }
}
