import 'dart:io';
import 'package:gnade_app/src/imports/imports.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../../services/pdf_generator_service.dart';

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
              onPressed: () async {
                try {
                  showGlobalToast(message: 'Generating PDF receipt...');
                  final pdfBytes = await PdfGeneratorService.instance.generateA4Receipt(data);
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdfBytes,
                    name: 'Receipt_${data.invoiceNo}',
                  );
                } catch (e) {
                  showGlobalToast(message: 'Failed to generate PDF.', status: 'error');
                }
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
              onPressed: () async {
                try {
                  showGlobalToast(message: 'Preparing PDF to share...');
                  final pdfBytes = await PdfGeneratorService.instance.generateA4Receipt(data);
                  final tempDir = await getTemporaryDirectory();
                  final file = File('${tempDir.path}/Receipt_${data.invoiceNo}.pdf');
                  await file.writeAsBytes(pdfBytes);


                  await ShareService.instance.shareFiles(
                    [file.path],
                    subject: 'Invoice Receipt #${data.invoiceNo}',
                  );
                } catch (e) {
                  showGlobalToast(message: 'Failed to share receipt.', status: 'error');
                }
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
