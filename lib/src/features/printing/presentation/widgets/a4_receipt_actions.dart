import 'package:gnade_app/src/imports/imports.dart';

class A4ReceiptActions extends StatelessWidget {
  final ReceiptData data;

  const A4ReceiptActions({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Print PDF (Primary Blue)
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showGlobalToast(message: 'Generating A4 PDF Document...');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'Print PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),

        // Share PDF (Light Blue Outline/Fill)
        Expanded(
          child: SizedBox(
            height: 42.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF1E40AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Trigger Share Mock using share_plus
                final shareText =
                    'Invoice #${data.invoiceNo} for ${data.customerName}\n'
                    'Total due: ₦${data.total.toStringAsFixed(0)}\n'
                    'Thank you for shopping at ${data.businessName}!';
                SharePlus.instance.share(
                  ShareParams(text: shareText),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_outlined,
                      color: const Color(0xFF1E40AF), size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Share Invoice',
                    style: TextStyle(
                      color: const Color(0xFF1E40AF),
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
