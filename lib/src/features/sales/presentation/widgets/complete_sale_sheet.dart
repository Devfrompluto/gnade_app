import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gnade_app/src/imports/core_imports.dart';
import '../providers/sales_providers.dart';

class CompleteSaleSheet extends ConsumerStatefulWidget {
  final double total;
  final bool isUnpaid;
  final String paymentStatus;
  final String initialPartialText;
  final String initialPaymentMethod;
  final Future<void> Function(double amountReceived, String selectedMethod) onConfirm;

  const CompleteSaleSheet({
    super.key,
    required this.total,
    required this.isUnpaid,
    required this.paymentStatus,
    required this.initialPartialText,
    required this.initialPaymentMethod,
    required this.onConfirm,
  });

  @override
  ConsumerState<CompleteSaleSheet> createState() => _CompleteSaleSheetState();
}

class _CompleteSaleSheetState extends ConsumerState<CompleteSaleSheet> {
  late TextEditingController _amountController;
  late String _selectedMethod;
  late double _amountReceived;
  late List<double> _quickAmounts;

  @override
  void initState() {
    super.initState();
    final initialPartialVal = double.tryParse(widget.initialPartialText) ?? (widget.total / 2);

    _amountController = TextEditingController(
      text: widget.paymentStatus == 'Partial'
          ? widget.initialPartialText
          : (widget.isUnpaid ? '0.00' : widget.total.toStringAsFixed(2)),
    );
    
    _selectedMethod = widget.isUnpaid ? 'Credit' : widget.initialPaymentMethod;
    
    _amountReceived = widget.paymentStatus == 'Partial'
        ? initialPartialVal
        : (widget.isUnpaid ? 0.0 : widget.total);

    _generateQuickAmounts();
  }

  void _generateQuickAmounts() {
    final total = widget.total;
    final ceil1k = (total / 1000).ceil() * 1000.0;
    final ceil5k = (total / 5000).ceil() * 5000.0;
    final ceil10k = (total / 10000).ceil() * 10000.0;

    _quickAmounts = [];
    if (ceil1k > total) _quickAmounts.add(ceil1k);
    if (ceil5k > ceil1k) _quickAmounts.add(ceil5k);
    if (ceil10k > ceil5k) _quickAmounts.add(ceil10k);

    while (_quickAmounts.length < 3) {
      final lastVal = _quickAmounts.isEmpty ? total : _quickAmounts.last;
      _quickAmounts.add(((lastVal + 1000) / 1000).ceil() * 1000.0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountPill({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(salesCheckoutProvider);
    final changeDue = _amountReceived > widget.total ? _amountReceived - widget.total : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Header title + Close X button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Complete Sale',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: const Color(0xFF64748B), size: 20.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Total Due section
          Center(
            child: Column(
              children: [
                Text(
                  'TOTAL DUE',
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₦ ${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF0F9F68),
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── Failure State Warning ──────────────────────────────────
          if (checkoutState.hasError) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: const Color(0xFFDC2626), size: 18.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      checkoutState.error is Failure
                          ? (checkoutState.error as Failure).message
                          : 'Failed to record sale: ${checkoutState.error}',
                      style: TextStyle(
                        color: const Color(0xFFDC2626),
                        fontSize: 11.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],

          // ── Unpaid Credit Warning ──────────────────────────────────
          if (widget.isUnpaid) ...[ 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: const Color(0xFFDC2626), size: 18.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Unpaid / Debt Sale: The customer will receive goods on credit. An outstanding balance of ₦ ${widget.total.toStringAsFixed(2)} will be logged.',
                      style: TextStyle(
                        color: const Color(0xFFDC2626),
                        fontSize: 11.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ] else ...[ 
            // ── Payment Method Selector ────────────────────────────
            Text(
              'Payment Method',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodCard(
                    title: 'Cash',
                    icon: Icons.payments_outlined,
                    isSelected: _selectedMethod == 'Cash',
                    onTap: () => setState(() => _selectedMethod = 'Cash'),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _buildPaymentMethodCard(
                    title: 'Mobile',
                    icon: Icons.phone_android_outlined,
                    isSelected: _selectedMethod == 'Mobile',
                    onTap: () => setState(() => _selectedMethod = 'Mobile'),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: _buildPaymentMethodCard(
                    title: 'Bank',
                    icon: Icons.account_balance_outlined,
                    isSelected: _selectedMethod == 'Bank',
                    onTap: () => setState(() => _selectedMethod = 'Bank'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Amount Received Input ──────────────────────────────
            Text(
              'Amount Received (₦)',
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                onChanged: (val) {
                  setState(() {
                    _amountReceived = double.tryParse(val) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  prefixText: '₦  ',
                  prefixStyle: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 14.h, horizontal: 12.w),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // ── Quick Amount Pills ────────────────────────────────
            Row(
              children: _quickAmounts
                  .take(3)
                  .map(
                    (amount) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _buildQuickAmountPill(
                        text: '₦${(amount / 1000).toStringAsFixed(0)}k',
                        onTap: () {
                          _amountController.text = amount.toStringAsFixed(0);
                          setState(() => _amountReceived = amount);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 14.h),

            // ── Change Due Banner ─────────────────────────────────
            if (changeDue > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Due',
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      '₦ ${changeDue.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: const Color(0xFF059669),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            // ── Partial validation warning ────────────────────────
            if (widget.paymentStatus == 'Partial' && _amountReceived >= widget.total)
              Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Amount paid cannot be equal to or greater than the total for a partial payment.',
                  style: TextStyle(
                    color: const Color(0xFFDC2626),
                    fontSize: 11.sp,
                  ),
                ),
              ),
            SizedBox(height: 20.h),
          ],

          // ── Confirm Button ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isUnpaid
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF0F9F68),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              onPressed: checkoutState.isLoading
                  ? null
                  : () async {
                      // Block partial if amount >= total
                      if (widget.paymentStatus == 'Partial' && _amountReceived >= widget.total) {
                        return;
                      }
                      // Block partial if field is empty / zero
                      if (widget.paymentStatus == 'Partial' && _amountReceived <= 0) {
                        return;
                      }
                      
                      await widget.onConfirm(_amountReceived, _selectedMethod);
                    },
              child: checkoutState.isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      widget.isUnpaid ? 'Confirm Debt / Unpaid Sale' : 'Confirm Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 14.h),

          // Cancel link
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFFEF4444),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
