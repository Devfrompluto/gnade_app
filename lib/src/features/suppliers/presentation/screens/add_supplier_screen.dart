import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/suppliers_providers.dart';

class AddSupplierScreen extends ConsumerStatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  ConsumerState<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends ConsumerState<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtr = TextEditingController();
  final _categoryCtr = TextEditingController();
  final _contactPersonCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _creditTermsCtr = TextEditingController();
  final _notesCtr = TextEditingController();

  bool _isLoading = false;

  final List<String> _categories = [
    'Beverages',
    'Logistics',
    'Groceries',
    'Raw Materials',
    'General Supplies',
    'Packaging',
    'Equipment',
  ];

  @override
  void dispose() {
    _nameCtr.dispose();
    _categoryCtr.dispose();
    _contactPersonCtr.dispose();
    _phoneCtr.dispose();
    _emailCtr.dispose();
    _creditTermsCtr.dispose();
    _notesCtr.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'Select Supplier Category',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 12.h),
                Divider(height: 1, color: Colors.grey.shade200),
                SizedBox(height: 8.h),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _categoryCtr.text == cat;
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                        title: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: const Color(0xFF1E40AF), size: 20.sp)
                            : null,
                        onTap: () {
                          setState(() {
                            _categoryCtr.text = cat;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final name = _nameCtr.text.trim();
    final phone = _phoneCtr.text.trim();
    final category = _categoryCtr.text.trim();
    final contactPerson = _contactPersonCtr.text.trim();
    final email = _emailCtr.text.trim();
    final creditTerms = _creditTermsCtr.text.trim();
    final notes = _notesCtr.text.trim();

    final result = await ref.read(suppliersProvider.notifier).addSupplier(
          name: name,
          phone: phone.isEmpty
              ? '+2340000000000'
              : (phone.startsWith('+') ? phone : '+234$phone'),
          category: category,
          contactPerson: contactPerson,
          email: email,
          creditTerms: creditTerms,
          notes: notes,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result != null) {
        showGlobalToast(message: 'Supplier "$name" added successfully');
        context.pop();
      } else {
        showGlobalToast(message: 'Failed to save supplier. Please try again.');
      }
    }
  }

  void _handleImportFromContacts() {
    showGlobalToast(message: 'Importing contact details...');
    // Pre-fill demo contact data
    setState(() {
      _nameCtr.text = 'Apex Distributors';
      _contactPersonCtr.text = 'Sarah Jenkins';
      _phoneCtr.text = '8099887766';
      _emailCtr.text = 'orders@apexdistributors.com';
      _categoryCtr.text = 'Beverages';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: 'Add Supplier',
        onBackPressed: () => context.pop(),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: Text(
              'Save',
              style: TextStyle(
                color: const Color(0xFF1E40AF),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Import from Contacts Button
                GestureDetector(
                  onTap: _handleImportFromContacts,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.r),
                      border:
                          Border.all(color: const Color(0xFFDBEAFE), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_ind_outlined,
                          color: const Color(0xFF1E40AF),
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Import from Contacts',
                          style: TextStyle(
                            color: const Color(0xFF1E40AF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Card 1: BUSINESS DETAILS
                _buildCardSection(
                  title: 'BUSINESS DETAILS',
                  children: [
                    AppTextField(
                      controller: _nameCtr,
                      enabled: !_isLoading,
                      label: 'Supplier Name *',
                      validator: (v) {
                        if (AppUtils.isBlank(v)) {
                          return 'Supplier name is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: _isLoading ? null : _showCategoryPicker,
                      child: AbsorbPointer(
                        child: AppTextField(
                          controller: _categoryCtr,
                          enabled: !_isLoading,
                          label: 'Supplier Category',
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Card 2: CONTACT INFORMATION
                _buildCardSection(
                  title: 'CONTACT INFORMATION',
                  children: [
                    AppTextField(
                      controller: _contactPersonCtr,
                      enabled: !_isLoading,
                      label: 'Contact Person Name',
                    ),
                    SizedBox(height: 14.h),

                    // Phone Number with Country Code Prefix
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 14.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Text('🇳🇬', style: TextStyle(fontSize: 14.sp)),
                              SizedBox(width: 4.w),
                              Text(
                                '+234',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: AppTextField(
                            controller: _phoneCtr,
                            enabled: !_isLoading,
                            label: 'Phone Number *',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (AppUtils.isBlank(v)) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    AppTextField(
                      controller: _emailCtr,
                      enabled: !_isLoading,
                      label: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Card 3: TERMS & LOGISTICS
                _buildCardSection(
                  title: 'TERMS & LOGISTICS',
                  children: [
                    AppTextField(
                      controller: _creditTermsCtr,
                      enabled: !_isLoading,
                      label: 'Credit Terms (e.g. Net 30)',
                    ),
                    SizedBox(height: 14.h),
                    AppTextField(
                      controller: _notesCtr,
                      enabled: !_isLoading,
                      label: 'Notes',
                      maxLines: 4,
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Bottom Action Buttons
                AppButton(
                  label: 'Save Supplier',
                  prefixIcon: Icon(Icons.save_outlined,
                      color: Colors.white, size: 18.sp),
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleSave,
                  isFullWidth: true,
                ),
                SizedBox(height: 10.h),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: const Color(0xFF334155),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }
}
