import 'dart:io';
import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'package:gnade_app/src/services/pdf_generator_service.dart';

void showShareReceiptSheet(BuildContext context, ReceiptData receiptData) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => ShareReceiptOptionsSheet(receiptData: receiptData),
  );
}

class ShareReceiptOptionsSheet extends StatefulWidget {
  final ReceiptData receiptData;

  const ShareReceiptOptionsSheet({
    super.key,
    required this.receiptData,
  });

  @override
  State<ShareReceiptOptionsSheet> createState() => _ShareReceiptOptionsSheetState();
}

class _ShareReceiptOptionsSheetState extends State<ShareReceiptOptionsSheet> {
  String? _loadingFormat; // 'pos' | 'a4' | null

  Future<void> _shareFormat(String format) async {
    setState(() => _loadingFormat = format);
    try {
      showGlobalToast(
        message: format == 'pos'
            ? 'Generating POS thermal receipt...'
            : 'Generating A4 invoice...',
      );

      final pdfBytes = format == 'pos'
          ? await PdfGeneratorService.instance.generatePosReceipt(widget.receiptData)
          : await PdfGeneratorService.instance.generateA4Receipt(widget.receiptData);

      final tempDir = await getTemporaryDirectory();
      final suffix = format == 'pos' ? 'POS' : 'A4';
      final fileName = 'Receipt_${widget.receiptData.invoiceNo}_$suffix.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (mounted) Navigator.pop(context);

      await ShareService.instance.shareFiles(
        [file.path],
        subject: 'Invoice Receipt #${widget.receiptData.invoiceNo}',
      );
    } catch (e) {
      if (mounted) setState(() => _loadingFormat = null);
      showGlobalToast(message: 'Failed to generate receipt to share.', status: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Title
          Text(
            'Select Receipt Format',
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Choose the receipt format you want to generate and share.',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),

          // Option 1: POS Thermal Slip
          _buildOptionTile(
            context,
            formatKey: 'pos',
            title: 'Thermal POS Receipt',
            subtitle: 'Compact roll receipt format (58mm / 80mm). Ideal for quick sharing on WhatsApp or SMS.',
            icon: Icons.receipt_long_rounded,
            badgeText: 'Compact',
            badgeBg: const Color(0xFFEFF6FF),
            badgeFg: const Color(0xFF2563EB),
          ),
          SizedBox(height: 12.h),

          // Option 2: A4 Full Invoice
          _buildOptionTile(
            context,
            formatKey: 'a4',
            title: 'A4 Full Invoice Document',
            subtitle: 'Detailed corporate invoice format with business logo, breakdown, tax, and status stamp.',
            icon: Icons.picture_as_pdf_rounded,
            badgeText: 'Official',
            badgeBg: const Color(0xFFF0FDF4),
            badgeFg: const Color(0xFF16A34A),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String formatKey,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
  }) {
    final isLoading = _loadingFormat == formatKey;
    final isAnyLoading = _loadingFormat != null;

    return InkWell(
      onTap: isAnyLoading ? null : () => _shareFormat(formatKey),
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isLoading ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isLoading ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Badge Container
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF2563EB),
                        ),
                      )
                    : Icon(icon, color: const Color(0xFF2563EB), size: 22.sp),
              ),
            ),
            SizedBox(width: 12.w),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeFg,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11.5.sp,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
