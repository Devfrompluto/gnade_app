import 'package:gnade_app/src/imports/imports.dart';
import 'package:printing/printing.dart';
import 'package:gnade_app/src/services/pdf_generator_service.dart';

class A4ReceiptPreview extends StatelessWidget {
  final ReceiptData data;

  const A4ReceiptPreview({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 520.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: PdfPreview(
        build: (format) => PdfGeneratorService.instance.generateA4Receipt(data),
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canDebug: false,
        actions: const [],
        loadingWidget: const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF))),
      ),
    );
  }
}
