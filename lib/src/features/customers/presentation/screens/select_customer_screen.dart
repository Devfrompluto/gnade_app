import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_providers.dart';
import '../widgets/widgets.dart';

class SelectCustomerScreen extends ConsumerStatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  ConsumerState<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends ConsumerState<SelectCustomerScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch customer list provider with explicit generic type argument
    final List<CustomerMock> customers = ref.watch<List<CustomerMock>>(customerListProvider);

    // Filter customers based on search query
    final filteredCustomers = customers.where((customer) {
      final query = _searchQuery.toLowerCase().trim();
      if (query.isEmpty) return true;
      return customer.name.toLowerCase().contains(query) ||
          customer.phone.replaceAll(' ', '').contains(query.replaceAll(' ', ''));
    }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: const AppCustomAppBar(
          title: 'Select Customer',
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search Input & Add New Customer Button Card
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(AppSpacing.pagePadding.w),
                child: Column(
                  children: [
                    // Search box widget
                    CustomerSearchInput(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),

                    // Add Customer Button widget
                    AddCustomerHeaderButton(
                      onPressed: () {
                        // Navigate to Add Customer Form
                        context.push(AppRoutes.addCustomer);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // Filtered Customer List
              Expanded(
                child: filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'No customers found',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.pagePadding.w,
                          vertical: 10.h,
                        ),
                        itemCount: filteredCustomers.length,
                        separatorBuilder: (context, index) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final CustomerMock customer = filteredCustomers[index];

                          return CustomerListItemTile(
                            customer: customer,
                            onTap: () {
                              // Return the selected customer to the checkout screen
                              context.pop(customer);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
