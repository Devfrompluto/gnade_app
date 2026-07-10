import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

class MoreProfileSummaryCard extends ConsumerWidget {
  const MoreProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final name = (user?.name != null && user!.name!.isNotEmpty) ? user.name! : 'User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final role = user?.role?.toLowerCase() ?? 'staff';
    final userRoleLabel = switch (role) {
      'owner' => 'Admin',
      'manager' => 'Manager',
      _ => 'Staff',
    };

    final businessAsync = ref.watch(businessProfileProvider);
    final businessName = businessAsync.value?.name ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 60.w,
            height: 60.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A), // Dark blue
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  userRoleLabel,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Active Business Name Badge (replacing pencil icon)
          if (businessName.isNotEmpty)
            Container(
              constraints: BoxConstraints(maxWidth: 100.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Light blue Container
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                businessName,
                style: TextStyle(
                  color: const Color(0xFF1A56DB), // Blue text
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
