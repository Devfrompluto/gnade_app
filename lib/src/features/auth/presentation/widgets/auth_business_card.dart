import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/pin_entry_bottom_sheet.dart';

class AuthBusinessCard extends StatelessWidget {
  final BusinessSummary business;

  const AuthBusinessCard({
    super.key,
    required this.business,
  });

  Color _getAvatarColor(String name) {
    final char = name.isEmpty ? 'A' : name[0].toUpperCase();
    switch (char) {
      case 'A': case 'B': case 'C': case 'D':
        return const Color(0xFF1E3A8A); // G in white -> G maps to E-H color
      case 'E': case 'F': case 'G': case 'H':
        return const Color(0xFF1E3A8A); // dark blue
      case 'I': case 'J': case 'K': case 'L':
        return const Color(0xFF0F766E); // dark teal
      case 'M': case 'N': case 'O': case 'P':
        return const Color(0xFF65A30D); // lime
      case 'Q': case 'R': case 'S': case 'T':
        return const Color(0xFF6B21A8); // purple
      default:
        return const Color(0xFF0D9488); // teal
    }
  }

  Color _getRoleBgColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return const Color(0xFFEFF6FF); // light blue
      case 'manager':
        return const Color(0xFFEEF2F6); // light greyish/blue
      default:
        return const Color(0xFFF3E8FF); // light purple
    }
  }

  Color _getRoleTextColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return const Color(0xFF1A56DB); // blue
      case 'manager':
        return const Color(0xFF475569); // grey
      default:
        return const Color(0xFF7E22CE); // purple
    }
  }

  String _formatRole(String role) {
    final lower = role.toLowerCase();
    if (lower == 'staff') return 'Cashier';
    return role.substring(0, 1).toUpperCase() + role.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final avatarColor = _getAvatarColor(business.name);
    final roleBg = _getRoleBgColor(business.role);
    final roleText = _getRoleTextColor(business.role);
    final roleLabel = _formatRole(business.role);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: const BorderSide(color: Color(0xFFF1F5F9)),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => PinEntryBottomSheet.show(context, business),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              // Avatar (colored box with white letter)
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: avatarColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    business.name.isEmpty ? 'A' : business.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                              fontSize: 16.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: roleBg,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: roleText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Display category (as branch location fallback)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            business.category ?? 'Retail Store',
                            style: tt.bodyMedium?.copyWith(
                              color: const Color(0xFF64748B),
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
