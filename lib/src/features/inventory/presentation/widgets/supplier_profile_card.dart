import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class SupplierProfileCard extends StatelessWidget {
  final SupplierMock supplier;

  const SupplierProfileCard({
    super.key,
    required this.supplier,
  });

  Future<void> _launchIntent(BuildContext context, String urlString) async {
    try {
      if (await canLaunchUrl(Uri.parse(urlString))) {
        await launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication);
      } else {
        showGlobalToast(message: 'Could not launch contact application');
      }
    } catch (_) {
      showGlobalToast(message: 'Error launching application');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar
          Container(
            width: 76.w,
            height: 76.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A8A), // Dark blue/navy avatar
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : 'S',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Name
          Text(
            supplier.name,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 4.h),

          // Phone Number
          Text(
            supplier.phone,
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 20.h),

          // Quick Action Links Row (Call, Message, WhatsApp)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(
                icon: Icons.phone_rounded,
                label: 'Call',
                bgColor: const Color(0xFF2563EB), // Blue
                onTap: () => _launchIntent(context, 'tel:${supplier.phone}'),
              ),
              _buildQuickAction(
                icon: Icons.message_rounded,
                label: 'Message',
                bgColor: const Color(0xFF2563EB), // Blue
                onTap: () => _launchIntent(context, 'sms:${supplier.phone}'),
              ),
              _buildQuickAction(
                icon: Icons.chat_bubble_rounded, // Chat bubble/whatsapp style
                label: 'WhatsApp',
                bgColor: const Color(0xFF10B981), // Emerald Green
                onTap: () {
                  final cleanPhone = supplier.phone.replaceAll(RegExp(r'[+\s\-]'), '');
                  _launchIntent(context, 'https://wa.me/$cleanPhone');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF475569), // slate-600
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
