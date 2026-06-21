import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class SaleSuccessScreen extends StatelessWidget {
  final String invoiceNo;
  final double amountPaid;
  final double total;
  final String paymentMethod;
  /// 'Paid' | 'Partial' | 'Unpaid'
  final String paymentStatus;
  final DateTime dateTime;
  final ReceiptData? receiptData;

  const SaleSuccessScreen({
    super.key,
    required this.invoiceNo,
    required this.amountPaid,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.dateTime,
    this.receiptData,
  });

  Color get _statusBg => paymentStatus == 'Paid'
      ? const Color(0xFFECFDF5)
      : paymentStatus == 'Partial'
          ? const Color(0xFFFFF7ED)
          : const Color(0xFFFEF2F2);

  Color get _statusFg => paymentStatus == 'Paid'
      ? const Color(0xFF059669)
      : paymentStatus == 'Partial'
          ? const Color(0xFFD97706)
          : const Color(0xFFDC2626);

  IconData get _statusIcon => paymentStatus == 'Paid'
      ? Icons.check_circle_rounded
      : paymentStatus == 'Partial'
          ? Icons.timelapse_rounded
          : Icons.warning_amber_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final formattedDate = DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
    final isUnpaid = paymentStatus == 'Unpaid';
    final isPartial = paymentStatus == 'Partial';
    final balanceOwed = total - amountPaid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurface,
            size: 22.sp,
          ),
          onPressed: () => context.go(AppRoutes.selectItem),
        ),
        title: Text(
          'Transaction Complete',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 15.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding.w,
                  vertical: 20.h,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),

                    // ── Status Circle Icon ───────────────────────────────────
                    Center(
                      child: Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusBg,
                          boxShadow: [
                            BoxShadow(
                              color: _statusFg.withValues(alpha: 0.12),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _statusFg,
                            ),
                            child: Icon(
                              _statusIcon,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── Heading ──────────────────────────────────────────────
                    Text(
                      isUnpaid
                          ? 'Sale Recorded (Debt)'
                          : isPartial
                              ? 'Partial Payment Recorded'
                              : 'Payment Successful!',
                      style: TextStyle(
                        color: _statusFg,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Transaction #$invoiceNo has been\nrecorded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // ── Summary Card ─────────────────────────────────────────
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              children: [
                                // Amount paid label
                                Text(
                                  isUnpaid ? 'TOTAL OWED' : 'AMOUNT PAID',
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  isUnpaid
                                      ? '₦ ${total.toStringAsFixed(2)}'
                                      : '₦ ${amountPaid.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _statusFg,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                // Balance owed row for partial
                                if (isPartial) ...[ 
                                  SizedBox(height: 10.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Balance Owed',
                                          style: TextStyle(
                                            color: const Color(0xFFDC2626),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '₦ ${balanceOwed.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: const Color(0xFFDC2626),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Dashed divider
                          CustomPaint(
                            size: Size(double.infinity, 1.h),
                            painter: DashedLinePainter(),
                          ),

                          // Payment method + status + date row
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 18.w, vertical: 14.h),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payments_outlined,
                                          color: const Color(0xFF64748B),
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          '$paymentMethod Payment',
                                          style: TextStyle(
                                            color: const Color(0xFF334155),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: const Color(0xFF64748B),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                // Payment Status Pill
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: _statusBg,
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon,
                                              color: _statusFg, size: 12.sp),
                                          SizedBox(width: 4.w),
                                          Text(
                                            paymentStatus.toUpperCase(),
                                            style: TextStyle(
                                              color: _statusFg,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Decorative wave card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        height: 100.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 1,
                          ),
                        ),
                        child: CustomPaint(painter: PremiumWavePainter()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer Buttons ───────────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding.w,
                vertical: 14.h,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E40AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        context.push(
                          AppRoutes.printReceipt,
                          extra: receiptData ?? _createFallbackReceiptData(),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.print_outlined,
                              color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Print Receipt',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF1E40AF), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () {
                        showGlobalToast(message: 'Opening share options...');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_outlined,
                              color: const Color(0xFF1E40AF), size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Share Receipt',
                            style: TextStyle(
                              color: const Color(0xFF1E40AF),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.selectItem),
                    child: Text(
                      'New Sale',
                      style: TextStyle(
                        color: const Color(0xFF1E40AF),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  ReceiptData _createFallbackReceiptData() {
    return ReceiptData(
      businessName: 'GNADE MULTICONCEPT',
      businessAddress: '123 Market Street, Victoria Island, Lagos',
      businessPhone: '+234 800 123 4567',
      businessEmail: 'contact@gnademulticoncept.com',
      invoiceNo: invoiceNo,
      dateTime: dateTime,
      customerName: 'Retail Customer',
      customerType: 'Regular Customer',
      items: const [
        ReceiptItem(
          name: 'Mojito Can - 330ml',
          quantity: 1,
          unitPrice: 11500,
          total: 11500,
        ),
        ReceiptItem(
          name: 'Avocado Toast',
          quantity: 2,
          unitPrice: 8000,
          total: 16000,
        ),
      ],
      subtotal: total / 1.075,
      tax: total - (total / 1.075),
      total: total,
      amountPaid: amountPaid,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
    );
  }
}

// Custom Painter — dashed divider
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter — premium wave illustration
class PremiumWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final wavePaint1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.1,
          size.width * 0.65, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.7,
          size.width, size.height * 0.35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, wavePaint1);

    final wavePaint2 = Paint()
      ..color = const Color(0xFF1D4ED8).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.8,
          size.width * 0.55, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.2,
          size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, wavePaint2);

    final wavePaint3 = Paint()
      ..color = const Color(0xFF1E3A8A).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    final path3 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.5,
          size.width * 0.7, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.9,
          size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path3, wavePaint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
