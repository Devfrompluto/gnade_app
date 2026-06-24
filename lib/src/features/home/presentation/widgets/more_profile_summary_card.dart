import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

class MoreProfileSummaryCard extends ConsumerWidget {
  const MoreProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final user = session.user;
    final email = user?.email ?? 'gnade.admin@example.com';
    final name = (user?.name != null && user!.name!.isNotEmpty) ? user.name! : 'Gnade Multiconcept';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'G';

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
          // Name and Email
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
                  email,
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          // Edit Pencil Icon
          GestureDetector(
            onTap: () => showGlobalToast(message: 'Edit profile coming soon!'),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF), // Light blue tint
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.edit_rounded,
                  color: const Color(0xFF2563EB), // Blue icon
                  size: 18.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
