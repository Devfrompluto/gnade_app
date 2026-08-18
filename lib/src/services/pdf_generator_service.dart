import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../features/printing/domain/entities/receipt_data.dart';

/// ─── Color Palette ─────────────────────────────────────────────────
/// Professional blue / grey / black theme
const _primaryBlue = PdfColor.fromInt(0xFF1E40AF); // Deep blue
const _accentBlue = PdfColor.fromInt(0xFF3B82F6); // Bright blue
const _lightBlue = PdfColor.fromInt(0xFFDBEAFE); // Blue-100
const _paleBlue = PdfColor.fromInt(0xFFEFF6FF); // Blue-50

const _darkText = PdfColor.fromInt(0xFF0F172A); // Slate-900
const _mediumText = PdfColor.fromInt(0xFF334155); // Slate-700
const _lightText = PdfColor.fromInt(0xFF64748B); // Slate-500


const _borderColor = PdfColor.fromInt(0xFFE2E8F0); // Slate-200
const _rowAlt = PdfColor.fromInt(0xFFF8FAFC); // Slate-50

const _stampGreen = PdfColor.fromInt(0xFF10B981);
const _stampAmber = PdfColor.fromInt(0xFFD97706);
const _stampRed = PdfColor.fromInt(0xFFDC2626);

class PdfGeneratorService {
  PdfGeneratorService._();
  static final PdfGeneratorService instance = PdfGeneratorService._();

  String _formatFullDate(DateTime dt) => DateFormat('MMMM d, yyyy').format(dt);
  String _formatTime(DateTime dt) => '${DateFormat('HH:mm').format(dt)} WAT';

  /// Try to download the business logo from a URL.
  /// Returns null if the URL is missing or the download fails.
  Future<pw.MemoryImage?> _loadLogoImage(String? logoUrl) async {
    if (logoUrl == null || logoUrl.isEmpty) return null;
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        logoUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        return pw.MemoryImage(Uint8List.fromList(response.data!));
      }
    } catch (_) {
      // Silently fail — fallback to text initials
    }
    return null;
  }

  Future<Uint8List> generateA4Receipt(ReceiptData data) async {
    final pdf = pw.Document();
    final logoImage = await _loadLogoImage(data.businessLogoUrl);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ═══════════════════════════════════════════════════════
              // HEADER — Blue accent bar + Logo + Business info
              // ═══════════════════════════════════════════════════════
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: _paleBlue,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: _lightBlue, width: 1),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Logo or Initials Circle
                    _buildLogoWidget(logoImage, data.businessName),
                    pw.SizedBox(width: 16),
                    // Business details
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            _cleanText(data.businessName),
                            style: const pw.TextStyle(
                              color: _primaryBlue,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            _cleanText(data.businessAddress),
                            style: const pw.TextStyle(color: _mediumText, fontSize: 9),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            _cleanText('Tel: ${data.businessPhone}${data.businessEmail != null ? '  |  ${data.businessEmail}' : ''}'),
                            style: const pw.TextStyle(color: _lightText, fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    // INVOICE badge
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: _primaryBlue,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        'INVOICE',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ═══════════════════════════════════════════════════════
              // META ROW — Invoice details + Billed To
              // ═══════════════════════════════════════════════════════
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Invoice metadata
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice Details',
                          style: const pw.TextStyle(color: _primaryBlue, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      _metaRow('Invoice No:', data.invoiceNo),
                      pw.SizedBox(height: 4),
                      _metaRow('Date:', _formatFullDate(data.dateTime)),
                      pw.SizedBox(height: 4),
                      _metaRow('Time:', _formatTime(data.dateTime)),
                    ],
                  ),
                  // Right: Billed To card
                  pw.Container(
                    width: 170,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _rowAlt,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: _borderColor, width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILLED TO',
                            style: const pw.TextStyle(color: _accentBlue, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                        pw.SizedBox(height: 6),
                        pw.Text(data.customerName,
                            style: const pw.TextStyle(color: _darkText, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        pw.SizedBox(height: 2),
                        pw.Text(data.customerType,
                            style: const pw.TextStyle(color: _lightText, fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // ITEMS TABLE
              // ═══════════════════════════════════════════════════════

              // Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: const pw.BoxDecoration(
                  color: _primaryBlue,
                  borderRadius: pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(6),
                    topRight: pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text('ITEM DESCRIPTION',
                          style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('QTY', textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('UNIT PRICE', textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('TOTAL', textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...data.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isAlt = index.isOdd;
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: pw.BoxDecoration(
                    color: isAlt ? _rowAlt : PdfColors.white,
                    border: const pw.Border(
                      bottom: pw.BorderSide(color: _borderColor, width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(_cleanText(item.name),
                            style: const pw.TextStyle(color: _mediumText, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(item.quantity.toStringAsFixed(0),
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(color: _mediumText, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            'N${NumberFormat('#,###').format(item.unitPrice)}',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(color: _mediumText, fontSize: 10)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                            'N${NumberFormat('#,###').format(item.total)}',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(color: _darkText, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════
              // STATUS STAMP + TOTALS
              // ═══════════════════════════════════════════════════════
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Status Stamp
                  pw.Expanded(
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Transform.rotateBox(
                        angle: -0.08,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: _stampColor(data.paymentStatus), width: 2.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            _stampText(data.paymentStatus),
                            style: pw.TextStyle(
                              color: _stampColor(data.paymentStatus),
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),

                  // Right: Totals Block
                  pw.Container(
                    width: 210,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: _paleBlue,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: _lightBlue, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        _totalsRow('Subtotal', 'N${NumberFormat('#,###').format(data.subtotal)}'),
                        if (data.tax > 0) ...[
                          pw.SizedBox(height: 6),
                          _totalsRow('Tax (7.5% VAT)', 'N${NumberFormat('#,###').format(data.tax)}'),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Divider(height: 1, color: _accentBlue),
                        pw.SizedBox(height: 8),
                        // TOTAL row
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('TOTAL',
                                style: const pw.TextStyle(color: _primaryBlue, fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            pw.Text('N${NumberFormat('#,###').format(data.total)}',
                                style: const pw.TextStyle(color: _primaryBlue, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        if (data.paymentStatus == 'Partial') ...[
                          pw.SizedBox(height: 6),
                          pw.Divider(height: 1, color: _borderColor),
                          pw.SizedBox(height: 6),
                          _totalsRow('Amount Paid', 'N${NumberFormat('#,###').format(data.amountPaid)}'),
                          pw.SizedBox(height: 4),
                          _totalsRow('Balance Owed', 'N${NumberFormat('#,###').format(data.total - data.amountPaid)}',
                              valueColor: _stampRed),
                        ] else if (data.paymentStatus == 'Unpaid') ...[
                          pw.SizedBox(height: 6),
                          pw.Divider(height: 1, color: _borderColor),
                          pw.SizedBox(height: 6),
                          _totalsRow('Amount Paid', 'N0'),
                          pw.SizedBox(height: 4),
                          _totalsRow('Outstanding', 'N${NumberFormat('#,###').format(data.total)}',
                              valueColor: _stampRed),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // ═══════════════════════════════════════════════════════
              // FOOTER
              // ═══════════════════════════════════════════════════════
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: _paleBlue,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your business!',
                      style: const pw.TextStyle(color: _primaryBlue, fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Items purchased in good condition cannot be returned after 7 days. '
                      'Please present this original receipt for any exchanges or claims. '
                      'All transactions are subject to our standard terms and conditions.',
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(color: _lightText, fontSize: 7),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generatePosReceipt(ReceiptData data) async {
    final pdf = pw.Document();
    final logoImage = await _loadLogoImage(data.businessLogoUrl);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginTop: 14,
          marginBottom: 14,
          marginLeft: 10,
          marginRight: 10,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (logoImage != null) ...[
                _buildLogoWidget(logoImage, data.businessName),
                pw.SizedBox(height: 6),
              ],
              // Business Name
              pw.Text(
                data.businessName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryBlue,
                ),
              ),
              if (data.businessAddress.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  data.businessAddress,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8, color: _mediumText),
                ),
              ],
              if (data.businessPhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Tel: ${data.businessPhone}',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8, color: _lightText),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, color: _borderColor),
              pw.SizedBox(height: 4),

              // Invoice Metadata
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice #: ${data.invoiceNo}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkText)),
                  pw.Text(DateFormat('dd/MM/yy HH:mm').format(data.dateTime), style: const pw.TextStyle(fontSize: 8, color: _lightText)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Customer: ${data.customerName}', style: const pw.TextStyle(fontSize: 8, color: _mediumText)),
                  pw.Text('Status: ${data.paymentStatus}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _stampColor(data.paymentStatus))),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, color: _borderColor),
              pw.SizedBox(height: 6),

              // Items Header
              pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.Text('ITEM', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkText))),
                  pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkText))),
                  pw.Expanded(flex: 2, child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkText))),
                ],
              ),
              pw.SizedBox(height: 4),
              ...data.items.map((item) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 2),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 4, child: pw.Text(_cleanText(item.name), style: const pw.TextStyle(fontSize: 8, color: _mediumText))),
                        pw.Expanded(flex: 1, child: pw.Text(item.quantity.toStringAsFixed(0), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: _mediumText))),
                        pw.Expanded(flex: 2, child: pw.Text('N${NumberFormat('#,##0').format(item.total)}', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _darkText))),
                      ],
                    ),
                  )),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, color: _borderColor),
              pw.SizedBox(height: 6),

              // Totals Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _primaryBlue)),
                  pw.Text('N${NumberFormat('#,##0').format(data.total)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _primaryBlue)),
                ],
              ),
              if (data.amountPaid > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Amount Paid:', style: const pw.TextStyle(fontSize: 8, color: _lightText)),
                    pw.Text('N${NumberFormat('#,##0').format(data.amountPaid)}', style: const pw.TextStyle(fontSize: 8, color: _mediumText)),
                  ],
                ),
              ],
              if (data.total - data.amountPaid > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Balance Due:', style: const pw.TextStyle(fontSize: 8, color: _stampRed)),
                    pw.Text('N${NumberFormat('#,##0').format(data.total - data.amountPaid)}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _stampRed)),
                  ],
                ),
              ],
              pw.SizedBox(height: 10),

              // Barcode Graphic & Footer
              pw.Text(
                '||| | ||||| || |||||| | |||| | |||',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _mediumText),
              ),
              pw.SizedBox(height: 2),
              pw.Text(data.invoiceNo, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7, color: _lightText)),
              pw.SizedBox(height: 8),

              pw.Text('Thank you for your business!\nPlease retain receipt for any claim within 7 days.', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 7, color: _lightText)),
              pw.SizedBox(height: 6),
              pw.Text('- - - - - - - - - Tear Here - - - - - - - - -', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6, color: _borderColor)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  static String _cleanText(String text) {
    return text
        .replaceAll('₦', 'N')
        .replaceAll('✂', '-')
        .replaceAll('•', '-');
  }

  /// Builds either a network-loaded logo image or a text-initials circle fallback.
  static pw.Widget _buildLogoWidget(pw.MemoryImage? logoImage, String businessName) {
    if (logoImage != null) {
      return pw.ClipRRect(
        horizontalRadius: 24,
        verticalRadius: 24,
        child: pw.Image(logoImage, width: 48, height: 48, fit: pw.BoxFit.cover),
      );
    }
    // Fallback: initials circle
    final initials = businessName.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    return pw.Container(
      width: 48,
      height: 48,
      decoration: const pw.BoxDecoration(
        color: _primaryBlue,
        shape: pw.BoxShape.circle,
      ),
      alignment: pw.Alignment.center,
      child: pw.Text(
        initials,
        style: const pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _metaRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(_cleanText(label),
            style: const pw.TextStyle(color: _lightText, fontSize: 9)),
        pw.SizedBox(width: 6),
        pw.Text(_cleanText(value),
            style: const pw.TextStyle(color: _darkText, fontWeight: pw.FontWeight.bold, fontSize: 9)),
      ],
    );
  }

  static pw.Widget _totalsRow(String label, String value, {PdfColor valueColor = _mediumText}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(_cleanText(label), style: const pw.TextStyle(color: _lightText, fontSize: 9)),
        pw.Text(_cleanText(value),
            style: pw.TextStyle(color: valueColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
      ],
    );
  }

  static PdfColor _stampColor(String status) {
    if (status == 'Paid') return _stampGreen;
    if (status == 'Partial') return _stampAmber;
    return _stampRed;
  }

  static String _stampText(String status) {
    if (status == 'Paid') return 'PAID IN FULL';
    if (status == 'Partial') return 'PARTIAL PAYMENT';
    return 'OUTSTANDING DEBT';
  }
}
