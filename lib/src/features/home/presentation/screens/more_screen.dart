import 'package:gnade_app/src/imports/imports.dart';
import 'package:gnade_app/src/features/auth/presentation/providers/session_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AppTopBar(title: 'More Menu'),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.xl.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'More settings & actions screen coming soon!',
              textAlign: TextAlign.center,
              style: context.theme.textTheme.bodyLarge,
            ),
            SizedBox(height: AppSpacing.xxl.h),
            AppButton(
              label: 'Logout',
              variant: ButtonVariant.danger,
              onPressed: () {
                ref.read(sessionProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
