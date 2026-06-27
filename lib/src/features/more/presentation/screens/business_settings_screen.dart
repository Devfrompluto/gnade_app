import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/app_settings_tile.dart';

class BusinessSettingsScreen extends ConsumerWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final name = (user?.name != null && user!.name!.isNotEmpty) ? user.name! : 'Gnade Multiconcept';

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
        child: SingleChildScrollView(
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
                      subtitle: name,
                      trailing: Icon(
                        Icons.edit_rounded,
                        color: const Color(0xFF2563EB),
                        size: 20.sp,
                      ),
                      onTap: () => showGlobalToast(message: 'Edit Business Name coming soon!'),
                    ),
                    AppSettingsTile(
                      title: 'Business Category',
                      subtitle: 'Retail / FMCG',
                      onTap: () => showGlobalToast(message: 'Category selection coming soon!'),
                    ),
                    AppSettingsTile(
                      title: 'Contact Number',
                      subtitle: '+234 801 234 5678',
                      onTap: () => showGlobalToast(message: 'Edit Contact Number coming soon!'),
                    ),
                    AppSettingsTile(
                      title: 'Business Address',
                      subtitle: '15 Trade Route Rd,\nLagos Mainland, Lagos',
                      onTap: () => showGlobalToast(message: 'Edit Business Address coming soon!'),
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
    );
  }
}
