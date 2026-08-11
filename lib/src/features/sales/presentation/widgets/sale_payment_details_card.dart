import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'payment_method_selector.dart';
import 'payment_status_selector.dart';

class SalePaymentDetailsCard extends StatelessWidget {
  final String paymentMethod;
  final String paymentStatus;
  final TextEditingController amountPaidController;
  final double total;
  final double balanceOwed;
  final bool isCustomerSelected;
  final ValueChanged<String> onMethodChanged;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onAmountChanged;

  const SalePaymentDetailsCard({
    super.key,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amountPaidController,
    required this.total,
    required this.balanceOwed,
    this.isCustomerSelected = true,
    required this.onMethodChanged,
    required this.onStatusChanged,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 12.h),

          // Payment Method Title
          Text(
            'Payment Method',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 8.h),
          PaymentMethodSelector(
            selectedMethod: paymentMethod,
            onMethodChanged: onMethodChanged,
            isCustomerSelected: isCustomerSelected,
          ),
          if (paymentMethod != 'Credit') ...[
            SizedBox(height: 16.h),
            // Payment Status Title
            Text(
              'Payment Status',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 8.h),
            PaymentStatusSelector(
              selectedStatus: paymentStatus,
              onStatusChanged: onStatusChanged,
              isCustomerSelected: isCustomerSelected,
            ),
            SizedBox(height: 16.h),
          ],

          // ─── Conditional Partial payment inputs ─────────────
          if (paymentStatus == 'Partial') ...[
            Text(
              'Amount Paid',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC), // soft input bg
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: amountPaidController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                onChanged: (_) => onAmountChanged(),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                    child: Text(
                      '₦',
                      style: TextStyle(
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Balance Owed Banner (Red)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance Owed',
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    '₦ ${balanceOwed > 0 ? balanceOwed.toStringAsFixed(2) : "0.00"}',
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (paymentStatus == 'Unpaid') ...[
            // Unpaid Owed Banner (Red)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: const Color(0xFFFCA5A5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFDC2626),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Balance Owed (Unpaid)',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                        ),
                        Text(
                          '₦ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(0xFFDC2626),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
