import 'package:gnade_app/src/imports/imports.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar (Skip Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Visibility(
                    visible: _currentPage < 2,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: const Color(0xFF2563EB), // Primary blue
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expanded PageView Area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Page 1
                  _buildPageContent(
                    illustration: Image.asset(
                      'assets/images/onboarding_1.png',
                      fit: BoxFit.contain,
                    ),
                    title: 'Track Every Sale',
                    subtitle:
                        'Record transactions in seconds, online or offline. Keep your business moving without delay.',
                  ),

                  // Page 2
                  _buildPageContent(
                    illustration: _buildPage2Illustration(),
                    title: 'Manage Your Inventory',
                    subtitle:
                        'Stay on top of your stock levels and get low-stock alerts before you run out.',
                  ),

                  // Page 3
                  _buildPageContent(
                    illustration: Image.asset(
                      'assets/images/onboarding_3.png',
                      fit: BoxFit.contain,
                    ),
                    title: 'Recover Debts Faster',
                    subtitle:
                        'Track partial payments and send professional reminders via WhatsApp.',
                  ),
                ],
              ),
            ),

            // Bottom Area (Indicators & Button)
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // 1. Custom Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: isActive ? 18.w : 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFF1A56DB) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 24.h),

                  // 2. Navigation Button
                  AppButton(
                    label: _currentPage < 2 ? 'Next' : 'Get Started',
                    suffixIcon: _currentPage < 2
                        ? Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16.sp,
                          )
                        : null,
                    isFullWidth: true,
                    height: ButtonSize.large,
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent({
    required Widget illustration,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          SizedBox(
            height: 300.h,
            width: double.infinity,
            child: illustration,
          ),
          SizedBox(height: 40.h),

          // Title
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 24.sp,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF475569),
                fontSize: 14.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Illustration() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft blue background
        borderRadius: BorderRadius.circular(24.r),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 220.w,
        height: 220.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingCard(
                  color: const Color(0xFF2563EB), // Blue
                  icon: Icons.inventory_2_rounded,
                  iconColor: Colors.white,
                  delayMs: 0,
                  floatEnd: -6.h,
                ),
                SizedBox(width: 16.w),
                _buildFloatingCard(
                  color: const Color(0xFFF1F5F9), // Light grey
                  icon: Icons.widgets_rounded,
                  iconColor: const Color(0xFF475569),
                  delayMs: 200,
                  floatEnd: -8.h,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingCard(
                  color: const Color(0xFFFEF3C7), // Peach
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFD97706),
                  delayMs: 400,
                  floatEnd: -5.h,
                ),
                SizedBox(width: 16.w),
                _buildFloatingCard(
                  color: const Color(0xFF0D9488), // Green
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.white,
                  delayMs: 600,
                  floatEnd: -7.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCard({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required int delayMs,
    required double floatEnd,
  }) {
    return Container(
      width: 90.w,
      height: 90.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 32.sp,
        ),
      ),
    )
    .animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    )
    .then(delay: Duration(milliseconds: delayMs))
    .slideY(
      begin: 0,
      end: floatEnd / 90.w,
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
    );
  }
}
