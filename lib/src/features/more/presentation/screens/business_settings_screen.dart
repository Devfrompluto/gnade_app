import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/app_settings_tile.dart';

class BusinessSettingsScreen extends ConsumerWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessProfileProvider);
    final businessId = ref.watch(sessionProvider).user?.businessId;
    final business = businessAsync.value;

    final businessName = business?.name ?? 'Kinetic Retail';
    final category = business?.category ?? 'General shop';
    final phone = business?.phone ?? 'Not set';
    final address = business?.address ?? 'Not set';

    const List<String> categories = [
      'General shop',
      'Retail',
      'Wholesale',
      'Restaurant / Food',
      'Services',
      'Apparel / Fashion',
      'Electronics',
      'Supermarket / Grocery',
      'Beauty / Cosmetics',
      'Pharmacy / Healthcare',
      'Other',
    ];

    Future<void> showEditDialog({
      required String title,
      required String initialValue,
      required String fieldKey,
      bool isDropdown = false,
      List<String>? dropdownItems,
    }) async {
      if (businessId == null || businessId.isEmpty) {
        showGlobalToast(message: 'No active business selected', status: 'error');
        return;
      }

      final controller = TextEditingController(text: initialValue == 'Not set' ? '' : initialValue);
      String? selectedDropdownValue = initialValue;
      final formKey = GlobalKey<FormState>();

      final confirm = await showAppDialog<bool>(
        child: Builder(
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (isDropdown && dropdownItems != null)
                      DropdownButtonFormField<String>(
                        initialValue: dropdownItems.contains(selectedDropdownValue)
                            ? selectedDropdownValue
                            : dropdownItems.first,
                        items: dropdownItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: dialogContext.theme.textTheme.bodyMedium?.copyWith(
                                color: dialogContext.theme.colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedDropdownValue = value;
                        },
                        validator: (v) => v == null ? 'Field is required' : null,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          isDense: true,
                        ),
                      )
                    else
                      AppTextField(
                        controller: controller,
                        label: title,
                        maxLines: fieldKey == 'address' ? 2 : 1,
                        keyboardType: fieldKey == 'phone' ? TextInputType.phone : TextInputType.text,
                        validator: (v) {
                          if (fieldKey != 'phone' && AppUtils.isBlank(v)) {
                            return 'Field cannot be empty';
                          }
                          return null;
                        },
                      ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            variant: ButtonVariant.outline,
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppButton(
                            label: 'Save',
                            onPressed: () {
                              if (formKey.currentState?.validate() ?? false) {
                                Navigator.of(dialogContext).pop(true);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      if (confirm ?? false) {
        final newValue = isDropdown ? selectedDropdownValue : controller.text.trim();
        if (newValue != initialValue) {
          if (!context.mounted) return;
          final result = await ref.read(authControllerProvider.notifier).updateBusinessProfile(
                businessId: businessId,
                name: fieldKey == 'name' ? newValue : null,
                category: fieldKey == 'category' ? newValue : null,
                phone: fieldKey == 'phone' ? newValue : null,
                address: fieldKey == 'address' ? newValue : null,
              );

          if (!context.mounted) return;

          result.fold(
            (failure) => showToast(context, message: failure.message, status: 'error'),
            (_) => showToast(context, message: 'Business settings updated successfully!', status: 'success'),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
      appBar: AppTopBar(
        title: 'Settings',
        centerTitle: true,
        titleWidget: Text(
          'Settings',
          style: TextStyle(
            color: const Color(0xFF1E3A8A), // Blue theme
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: businessAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1A56DB))),
          error: (err, stack) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load business profile',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: const Color(0xFF64748B), fontSize: 14.sp),
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: 'Retry',
                    onPressed: () => ref.invalidate(businessProfileProvider),
                  ),
                ],
              ),
            ),
          ),
          data: (_) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding.w,
                vertical: AppSpacing.md.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. BUSINESS PROFILE Section
                  SettingsGroupCard(
                    title: 'Business Profile',
                    children: [
                      AppSettingsTile(
                        title: 'Business Name',
                        subtitle: businessName,
                        trailing: Icon(
                          Icons.edit_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.sp,
                        ),
                        onTap: () => showEditDialog(
                          title: 'Business Name',
                          initialValue: businessName,
                          fieldKey: 'name',
                        ),
                      ),
                      AppSettingsTile(
                        title: 'Business Category',
                        subtitle: category,
                        trailing: Icon(
                          Icons.edit_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.sp,
                        ),
                        onTap: () => showEditDialog(
                          title: 'Business Category',
                          initialValue: category,
                          fieldKey: 'category',
                          isDropdown: true,
                          dropdownItems: categories,
                        ),
                      ),
                      AppSettingsTile(
                        title: 'Contact Number',
                        subtitle: phone,
                        trailing: Icon(
                          Icons.edit_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.sp,
                        ),
                        onTap: () => showEditDialog(
                          title: 'Contact Number',
                          initialValue: phone,
                          fieldKey: 'phone',
                        ),
                      ),
                      AppSettingsTile(
                        title: 'Business Address',
                        subtitle: address,
                        trailing: Icon(
                          Icons.edit_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.sp,
                        ),
                        onTap: () => showEditDialog(
                          title: 'Business Address',
                          initialValue: address,
                          fieldKey: 'address',
                        ),
                      ),
                    ],
                  ),

                  // 2. OPERATIONS Section
                  SettingsGroupCard(
                    title: 'Operations',
                    children: [
                      AppSettingsTile(
                        title: 'Tax Rate',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '0%',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: const Color(0xFF94A3B8),
                              size: 20.sp,
                            ),
                          ],
                        ),
                        onTap: () => showGlobalToast(message: 'Tax settings coming soon!'),
                      ),
                      AppSettingsTile(
                        title: 'Discount Policy',
                        onTap: () => showGlobalToast(message: 'Discount policy coming soon!'),
                      ),
                      AppSettingsTile(
                        title: 'Working Hours',
                        onTap: () => showGlobalToast(message: 'Working hours coming soon!'),
                      ),
                    ],
                  ),

                  // 3. BILLING Section
                  SettingsGroupCard(
                    title: 'Billing',
                    children: [
                      AppSettingsTile(
                        title: 'Subscription Plan',
                        trailing: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            'Pro Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => showGlobalToast(message: 'Subscription plan details coming soon!'),
                      ),
                      AppSettingsTile(
                        title: 'Payment Methods',
                        onTap: () => showGlobalToast(message: 'Payment methods coming soon!'),
                      ),
                    ],
                  ),

                  // 4. DATA Section
                  SettingsGroupCard(
                    title: 'Data',
                    children: [
                      AppSettingsTile(
                        title: 'Backup & Sync',
                        subtitle: 'Last synced: Today, 10:45 AM',
                        trailing: Icon(
                          Icons.sync_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20.sp,
                        ),
                        onTap: () => showGlobalToast(message: 'Data backup & sync triggered!'),
                      ),
                      AppSettingsTile(
                        title: 'Clear Cache',
                        trailing: Text(
                          '124 MB',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () => showGlobalToast(message: 'Cache cleared successfully!'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
