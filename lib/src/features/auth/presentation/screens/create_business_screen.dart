import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/features/auth/presentation/widgets/auth_create_business_form.dart';

class CreateBusinessScreen extends StatelessWidget {
  const CreateBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;

    void handleFormSubmit({
      required String name,
      required String category,
      required String address,
      String? phone,
      File? logoFile,
    }) {
      context.push(
        AppRoutes.createPin,
        extra: {
          'name': name,
          'category': category,
          'address': address,
          'phone': phone,
          'logoFile': logoFile,
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back arrow to match design
        title: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            'Create new business',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              fontSize: 20.sp,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A56DB),
                shape: const StadiumBorder(),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 18.w),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Widget
              AuthCreateBusinessForm(onSubmit: handleFormSubmit),
            ],
          ),
        ),
      ),
    );
  }
}
