import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/suppliers_providers.dart';
import '../../domain/entities/supplier.dart';
import '../widgets/supplier_card.dart';
import '../widgets/suppliers_metrics_header.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchCtr = TextEditingController();

  final List<Color> _avatarColors = const [
    Color(0xFF1E3A8A), // Navy
    Color(0xFF0D9488), // Teal
    Color(0xFF059669), // Emerald
    Color(0xFF7C3AED), // Purple
    Color(0xFFD97706), // Amber
  ];

  @override
  void dispose() {
    _searchCtr.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await ref.read(suppliersProvider.notifier).loadSuppliers();
  }

  Color _getAvatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = theme.textTheme;

    final suppliersAsync = ref.watch(suppliersProvider);
    final searchQuery = ref.watch(supplierSearchQueryProvider);
    final hasSuppliers = (suppliersAsync.value ?? []).isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: 'Suppliers',
        onBackPressed: () => context.pop(),
      ),
      floatingActionButton: hasSuppliers
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.addSupplier),
              backgroundColor: const Color(0xFF1E40AF),
              elevation: 3,
              child: Icon(Icons.add, color: Colors.white, size: 24.sp),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF1E40AF),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14.h),

                // Top Metrics Cards
                SuppliersMetricsHeader(asyncList: suppliersAsync),
                SizedBox(height: 16.h),

                // Search Bar
                AppTextField(
                  controller: _searchCtr,
                  hint: 'Search suppliers...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Icon(
                      Icons.search_rounded,
                      color: const Color(0xFF64748B),
                      size: 20.sp,
                    ),
                  ),
                  onChanged: (val) {
                    ref.read(supplierSearchQueryProvider.notifier).state = val.trim();
                  },
                ),
                SizedBox(height: 18.h),

                // Section Title Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Suppliers',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        fontSize: 16.sp,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showGlobalToast(message: 'Filter suppliers');
                      },
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              size: 16.sp,
                              color: const Color(0xFF1E40AF),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Filter',
                              style: TextStyle(
                                color: const Color(0xFF1E40AF),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Suppliers List
                _buildSuppliersList(suppliersAsync, searchQuery),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuppliersList(AsyncValue<List<Supplier>> asyncList, String query) {
    return asyncList.when(
      data: (suppliers) {
        final filtered = suppliers.where((s) {
          if (query.isEmpty) return true;
          final q = query.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.phone.contains(q) ||
              (s.category?.toLowerCase().contains(q) ?? false);
        }).toList();

        if (filtered.isEmpty) {
          final isSearching = query.isNotEmpty;
          return Padding(
            padding: EdgeInsets.only(top: 40.h, bottom: 40.h),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppEmptyState(
                    title: isSearching ? 'No matching suppliers' : 'No suppliers added yet',
                    subtitle: isSearching
                        ? 'No suppliers match "$query". Try searching for another name or phone number.'
                        : 'Add your suppliers to easily manage orders, purchases, and debt records.',
                  ),
                  if (!isSearching) ...[
                    SizedBox(height: 20.h),
                    AppButton(
                      label: 'Add Supplier',
                      prefixIcon: Icon(Icons.add, color: Colors.white, size: 18.sp),
                      onPressed: () => context.push(AppRoutes.addSupplier),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final supplier = filtered[index];
            final avatarBg = _getAvatarColor(index);

            return SupplierCard(
              supplier: supplier,
              avatarBg: avatarBg,
              onTap: () {
                context.push('/products/supplier/${supplier.id}');
              },
            );
          },
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            return Container(
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          },
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            'Error loading suppliers: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
