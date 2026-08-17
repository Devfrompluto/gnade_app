import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MultiplePaymentResult {
  final double cashAmount;
  final double mobileAmount;
  final double bankAmount;
  final double totalPaid;
  final String formattedMethod;

  MultiplePaymentResult({
    required this.cashAmount,
    required this.mobileAmount,
    required this.bankAmount,
    required this.totalPaid,
    required this.formattedMethod,
  });
}

class MultiplePaymentSheet extends StatefulWidget {
  final double totalAmount;
  final double initialCash;
  final double initialMobile;
  final double initialBank;

  const MultiplePaymentSheet({
    super.key,
    required this.totalAmount,
    this.initialCash = 0.0,
    this.initialMobile = 0.0,
    this.initialBank = 0.0,
  });

  static Future<MultiplePaymentResult?> show(
    BuildContext context, {
    required double totalAmount,
    double initialCash = 0.0,
    double initialMobile = 0.0,
    double initialBank = 0.0,
  }) {
    return showModalBottomSheet<MultiplePaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MultiplePaymentSheet(
        totalAmount: totalAmount,
        initialCash: initialCash,
        initialMobile: initialMobile,
        initialBank: initialBank,
      ),
    );
  }

  @override
  State<MultiplePaymentSheet> createState() => _MultiplePaymentSheetState();
}

class _MultiplePaymentSheetState extends State<MultiplePaymentSheet> {
  late TextEditingController _cashController;
  late TextEditingController _mobileController;
  late TextEditingController _bankController;

  @override
  void initState() {
    super.initState();

    _cashController = TextEditingController(
      text: widget.initialCash > 0 ? widget.initialCash.toStringAsFixed(0) : '',
    );
    _mobileController = TextEditingController(
      text: widget.initialMobile > 0 ? widget.initialMobile.toStringAsFixed(0) : '',
    );
    _bankController = TextEditingController(
      text: widget.initialBank > 0 ? widget.initialBank.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _cashController.dispose();
    _mobileController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  double get _cash => double.tryParse(_cashController.text) ?? 0.0;
  double get _mobile => double.tryParse(_mobileController.text) ?? 0.0;
  double get _bank => double.tryParse(_bankController.text) ?? 0.0;
  double get _totalCollected => _cash + _mobile + _bank;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final primaryColor = Theme.of(context).primaryColor;
    final currencyFormat = NumberFormat('#,##0');
    final isMatching = (_totalCollected - widget.totalAmount).abs() < 0.01;
    final diff = _totalCollected - widget.totalAmount;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
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
            SizedBox(height: 14.h),

            // Header Title + Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Split Payment',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Sale Total: ₦ ${currencyFormat.format(widget.totalAmount)}',
                      style: TextStyle(
                        color: const Color(0xFF64748B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 22.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 18.h),

            // ── Clean Input Fields ───────────────────────────────────────
            _buildSimpleInputField(
              label: 'Cash Payment (₦)',
              controller: _cashController,
              primaryColor: primaryColor,
            ),
            SizedBox(height: 12.h),

            _buildSimpleInputField(
              label: 'Mobile / Transfer (₦)',
              controller: _mobileController,
              primaryColor: primaryColor,
            ),
            SizedBox(height: 12.h),

            _buildSimpleInputField(
              label: 'Bank / POS (₦)',
              controller: _bankController,
              primaryColor: primaryColor,
            ),
            SizedBox(height: 16.h),

            // ── Summary & Status ──────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isMatching
                    ? const Color(0xFFF0FDF4)
                    : (diff > 0 ? const Color(0xFFFEFCE8) : const Color(0xFFFEF2F2)),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isMatching
                      ? const Color(0xFF86EFAC)
                      : (diff > 0 ? const Color(0xFFFDE047) : const Color(0xFFFCA5A5)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Entered',
                        style: TextStyle(
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        diff.abs() < 0.01
                            ? 'Matches Total'
                            : (diff > 0
                                ? 'Overpaid by ₦${currencyFormat.format(diff)}'
                                : 'Underpaid by ₦${currencyFormat.format(diff.abs())}'),
                        style: TextStyle(
                          color: isMatching
                              ? const Color(0xFF15803D)
                              : (diff > 0 ? const Color(0xFFA16207) : const Color(0xFFB91C1C)),
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₦ ${currencyFormat.format(_totalCollected)}',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),

            // ── Apply Button ─────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final parts = <String>[];
                  if (_cash > 0) parts.add('Cash: ₦${currencyFormat.format(_cash)}');
                  if (_mobile > 0) parts.add('Transfer: ₦${currencyFormat.format(_mobile)}');
                  if (_bank > 0) parts.add('Bank: ₦${currencyFormat.format(_bank)}');

                  final formattedStr = parts.isNotEmpty
                      ? 'Multiple (${parts.join(", ")})'
                      : 'Multiple';

                  Navigator.pop(
                    context,
                    MultiplePaymentResult(
                      cashAmount: _cash,
                      mobileAmount: _mobile,
                      bankAmount: _bank,
                      totalPaid: _totalCollected,
                      formattedMethod: formattedStr,
                    ),
                  );
                },
                child: Text(
                  'Apply Split Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInputField({
    required String label,
    required TextEditingController controller,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            prefixText: '₦ ',
            prefixStyle: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: primaryColor, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
