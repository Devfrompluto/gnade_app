import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/customer_providers.dart';
import '../widgets/customer_profile_header.dart';
import '../widgets/customer_tabs_view.dart';
import 'add_customer_screen.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  final String id;

  const CustomerDetailsScreen({
    super.key,
    required this.id,
  });

  void _showCustomerOptionsMenu(BuildContext context, WidgetRef ref, Customer customer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: const Color(0xFF1E40AF), size: 22.sp),
                  title: Text(
                    'Edit Customer',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => AddCustomerScreen(initialCustomer: customer),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: const Color(0xFFDC2626), size: 22.sp),
                  title: Text(
                    'Delete Customer',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFFDC2626)),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDeleteCustomer(context, ref, customer);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteCustomer(BuildContext context, WidgetRef ref, Customer customer) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Delete Customer?',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          content: Text(
            'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await ref.read(customerListProvider.notifier).deleteCustomer(customer.id);
                if (success) {
                  showGlobalToast(message: 'Customer deleted successfully!');
                  if (context.mounted) {
                    context.pop();
                  }
                } else {
                  showGlobalToast(message: 'Failed to delete customer.', status: 'error');
                }
              },
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).user;
    final isAdminOrOwner = user?.isAdminOrOwner ?? true;

    if (!isAdminOrOwner) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const AppCustomAppBar(title: 'Customer Details'),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: const Center(
            child: AppEmptyState(
              title: 'Access Restricted',
              subtitle: 'Only business owners and admins can view customer details.',
            ),
          ),
        ),
      );
    }

    final customers = ref.watch(customerListProvider);
    final matches = customers.where((c) => c.id == id);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: const AppCustomAppBar(title: 'Customer Details'),
        body: const Center(child: Text('Customer not found')),
      );
    }
    final customer = matches.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: customer.name,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_rounded, color: const Color(0xFF0F172A), size: 20.sp),
            onPressed: () => _showCustomerOptionsMenu(context, ref, customer),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            // 1. Profile Avatar Header Card
            CustomerProfileHeader(customer: customer),
            SizedBox(height: 24.h),

            // 2. Modern Tabs Selector (History / Debt / Notes)
            CustomerTabsView(customer: customer),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
