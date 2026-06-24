import 'package:gnade_app/src/imports/imports.dart';
import '../providers/notifications_provider.dart';

class NotificationFilters extends ConsumerWidget {
  const NotificationFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(selectedNotificationFilterProvider);
    const filters = ['All', 'Sales', 'Stock', 'Expenses', 'Debts'];

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding.w),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = activeFilter == filter;

          return GestureDetector(
            onTap: () {
              ref.read(selectedNotificationFilterProvider.notifier).state = filter;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: isSelected
                    ? null
                    : Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
