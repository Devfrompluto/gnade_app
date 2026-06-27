import 'package:gnade_app/src/imports/imports.dart';
import '../widgets/more_profile_summary_card.dart';
import '../widgets/more_category_card.dart';
import '../widgets/more_setting_tile.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light grey background
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
                // 1. Profile Summary Card
                const MoreProfileSummaryCard(),
                SizedBox(height: 20.h),

                // 2. Settings Group
                MoreCategoryCard(
                  title: 'Settings',
                  children: [
                    MoreSettingTile(
                      title: 'App Settings',
                      icon: HugeIcons.strokeRoundedSlidersHorizontal,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => context.push(AppRoutes.appSettings),
                    ),
                    MoreSettingTile(
                      title: 'Business Settings',
                      icon: HugeIcons.strokeRoundedStore01,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => context.push(AppRoutes.businessSettings),
                    ),
                  ],
                ),

                // 3. Business Info Group
                MoreCategoryCard(
                  title: 'Business Info',
                  children: [
                    MoreSettingTile(
                      title: 'Returned Sales',
                      icon: Icons.keyboard_return_rounded,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEF2F2),
                      onTap: () => showGlobalToast(message: 'Returned Sales coming soon!'),
                    ),
                    MoreSettingTile(
                      title: 'Damaged Items',
                      icon: Icons.image_outlined,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFFFFBEB),
                      onTap: () => showGlobalToast(message: 'Damaged Items coming soon!'),
                    ),
                    MoreSettingTile(
                      title: 'Deleted Sales',
                      icon: Icons.history_rounded,
                      iconColor: const Color(0xFF64748B),
                      iconBgColor: const Color(0xFFF1F5F9),
                      onTap: () => showGlobalToast(message: 'Deleted Sales coming soon!'),
                    ),
                  ],
                ),

                // 4. People Group
                MoreCategoryCard(
                  title: 'People',
                  children: [
                    MoreSettingTile(
                      title: 'User Management',
                      icon: HugeIcons.strokeRoundedUserGroup,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => showGlobalToast(message: 'User Management coming soon!'),
                    ),
                    MoreSettingTile(
                      title: 'Suppliers',
                      icon: Icons.local_shipping_outlined,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => showGlobalToast(message: 'Suppliers coming soon!'),
                    ),
                  ],
                ),

                // 5. Support Group
                MoreCategoryCard(
                  title: 'Support',
                  children: [
                    MoreSettingTile(
                      title: 'Contact Us',
                      icon: Icons.headset_mic_outlined,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => showGlobalToast(message: 'Contact Us coming soon!'),
                    ),
                    MoreSettingTile(
                      title: 'Rate App',
                      icon: Icons.star_outline_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => showGlobalToast(message: 'Rate App coming soon!'),
                    ),
                    MoreSettingTile(
                      title: 'Privacy Policy',
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      onTap: () => showGlobalToast(message: 'Privacy Policy coming soon!'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
