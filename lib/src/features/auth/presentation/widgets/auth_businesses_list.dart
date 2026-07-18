import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/domain/entities/business_summary.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_business_card.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_empty_state.dart';

class AuthBusinessesList extends StatelessWidget {
  final List<BusinessSummary> businesses;
  final VoidCallback onRefresh;

  const AuthBusinessesList({
    super.key,
    required this.businesses,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        children: [
          SizedBox(height: 16.h),
          Text(
            'Select Business',
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A56DB),
              fontSize: 26.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Choose a business to manage or add a new one.',
            style: tt.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 32.h),

          if (businesses.isEmpty)
            const AuthEmptyState()
          else ...[
            ...businesses.map((business) => AuthBusinessCard(business: business)),
            SizedBox(height: 16.h),
          ],

          // Inline "+ Add New Business" Outline Button (Hidden for strict employees)
          if (businesses.isEmpty || businesses.any((b) => b.role == 'owner'))
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.createBusiness),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF1A56DB), width: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: const Color(0xFFF8FAFC),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: const Color(0xFF1A56DB),
                      size: 20.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Add New Business',
                      style: TextStyle(
                        color: const Color(0xFF1A56DB),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
