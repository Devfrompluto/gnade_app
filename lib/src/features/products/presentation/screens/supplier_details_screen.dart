import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';
import '../../../suppliers/presentation/providers/suppliers_providers.dart';
import '../widgets/supplier_profile_card.dart';
import '../widgets/supplier_metrics_row.dart';
import '../widgets/supplier_purchases_list.dart';

class SupplierDetailsScreen extends ConsumerWidget {
  final String id;

  const SupplierDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliers = ref.watch(suppliersListProvider);
    final newSuppliers = ref.watch(suppliersProvider).value ?? [];

    SupplierMock? foundSupplier;

    for (final s in suppliers) {
      if (s.id == id) {
        foundSupplier = s;
        break;
      }
    }

    if (foundSupplier == null) {
      for (final s in newSuppliers) {
        if (s.id == id) {
          foundSupplier = SupplierMock(
            id: s.id,
            name: s.name,
            phone: s.phone,
            supplyValue: '₦ ${NumberFormat('#,##0').format(s.supplyValue)}',
            debtAmount: '₦ ${NumberFormat('#,##0').format(s.debtAmount)}',
            purchases: const [],
          );
          break;
        }
      }
    }

    final supplier = foundSupplier ??
        (suppliers.isNotEmpty
            ? suppliers.first
            : (newSuppliers.isNotEmpty
                ? SupplierMock(
                    id: newSuppliers.first.id,
                    name: newSuppliers.first.name,
                    phone: newSuppliers.first.phone,
                    supplyValue: '₦ ${NumberFormat('#,##0').format(newSuppliers.first.supplyValue)}',
                    debtAmount: '₦ ${NumberFormat('#,##0').format(newSuppliers.first.debtAmount)}',
                    purchases: const [],
                  )
                : const SupplierMock(
                    id: 'default',
                    name: 'Supplier',
                    phone: '+2340000000000',
                    supplyValue: '₦ 0',
                    debtAmount: '₦ 0',
                    purchases: [],
                  )));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // light slate gray background
      appBar: AppCustomAppBar(
        title: 'Supplier Details',
        onBackPressed: () => context.pop(),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: const Color(0xFF1E293B), size: 20.sp),
            onPressed: () => showGlobalToast(message: 'Edit Supplier coming soon'),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: const Color(0xFFDC2626), size: 20.sp),
            onPressed: () => showGlobalToast(message: 'Delete Supplier coming soon'),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Card Component
            SupplierProfileCard(supplier: supplier),
            SizedBox(height: 16.h),

            // Supply and Debts Metrics Row Component
            SupplierMetricsRow(supplier: supplier),
            SizedBox(height: 24.h),

            // Purchases list section
            SupplierPurchasesList(supplier: supplier),
          ],
        ),
      ),
    );
  }
}
