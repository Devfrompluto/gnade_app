import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import '../widgets/settings_group_card.dart';
import '../widgets/app_settings_tile.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  bool _biometricEnabled = true;
  bool _salesAlertsEnabled = true;
  bool _lowStockAlertsEnabled = true;
  bool _debtRemindersEnabled = false;

  @override
  Widget build(BuildContext context) {
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
                // 1. GENERAL Section
                SettingsGroupCard(
                  title: 'General',
                  children: [
                    AppSettingsTile(
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () => showGlobalToast(message: 'Language selection coming soon!'),
                    ),
                    AppSettingsTile(
                      title: 'Currency',
                      subtitle: 'Nigerian Naira - ₦',
                      onTap: () => showGlobalToast(message: 'Currency selection coming soon!'),
                    ),
                  ],
                ),

                // 2. SECURITY Section
                SettingsGroupCard(
                  title: 'Security',
                  children: [
                    AppSettingsTile(
                      title: 'Change PIN',
                      onTap: () => showGlobalToast(message: 'Change PIN coming soon!'),
                    ),
                    AppSettingsTile(
                      title: 'Biometric Login',
                      trailing: _buildSwitch(
                        value: _biometricEnabled,
                        onChanged: (val) => setState(() => _biometricEnabled = val),
                      ),
                    ),
                  ],
                ),

                // 3. NOTIFICATIONS Section
                SettingsGroupCard(
                  title: 'Notifications',
                  children: [
                    AppSettingsTile(
                      title: 'Sales Alerts',
                      trailing: _buildSwitch(
                        value: _salesAlertsEnabled,
                        onChanged: (val) => setState(() => _salesAlertsEnabled = val),
                      ),
                    ),
                    AppSettingsTile(
                      title: 'Low Stock Alerts',
                      trailing: _buildSwitch(
                        value: _lowStockAlertsEnabled,
                        onChanged: (val) => setState(() => _lowStockAlertsEnabled = val),
                      ),
                    ),
                    AppSettingsTile(
                      title: 'Debt Reminders',
                      trailing: _buildSwitch(
                        value: _debtRemindersEnabled,
                        onChanged: (val) => setState(() => _debtRemindersEnabled = val),
                      ),
                    ),
                  ],
                ),

                // 4. APPEARANCE Section
                SettingsGroupCard(
                  title: 'Appearance',
                  children: [
                    AppSettingsTile(
                      title: 'Theme',
                      subtitle: 'Light Mode',
                      onTap: () => showGlobalToast(message: 'Theme customization coming soon!'),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // 5. Sign Out Button
                InkWell(
                  onTap: () => _handleLogout(context),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: const Color(0xFFDC2626),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch({required bool value, required ValueChanged<bool> onChanged}) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: const Color(0xFF2563EB),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE2E8F0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showAppDialog<bool>(
      child: Builder(
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AppBorders.dialog,
          ),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFDC2626),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Confirm Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to log out from Gnade Multiconcept?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF475569),
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: ButtonVariant.outline,
                        color: const Color(0xFF64748B),
                        textColor: const Color(0xFF64748B),
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppButton(
                        label: 'Logout',
                        variant: ButtonVariant.primary,
                        color: const Color(0xFFDC2626),
                        textColor: Colors.white,
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirm ?? false) {
      await ref.read(sessionProvider.notifier).logout();
    }
  }
}
