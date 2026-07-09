import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_businesses_list.dart';

class SelectBusinessScreen extends ConsumerWidget {
  const SelectBusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(userBusinessesProvider);
    final tt = context.textTheme;

    Future<void> handleLogout() async {
      final confirm = await showAppDialog<bool>(
        child: Builder(
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
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
                    'Are you sure you want to sign out?',
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
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppButton(
                          label: 'Logout',
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
        ref.read(sessionProvider.notifier).logout();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Select Business',
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            onPressed: handleLogout,
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: businessesAsync.when(
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
                    'Failed to load businesses',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: 'Retry',
                    onPressed: () => ref.invalidate(userBusinessesProvider),
                  ),
                ],
              ),
            ),
          ),
          data: (businesses) => AuthBusinessesList(
            businesses: businesses,
            onRefresh: () => ref.invalidate(userBusinessesProvider),
          ),
        ),
      ),
    );
  }
}
