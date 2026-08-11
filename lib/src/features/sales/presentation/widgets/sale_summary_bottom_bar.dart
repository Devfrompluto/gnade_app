import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gnade_app/src/theme/app_spacing.dart';

class SaleSummaryBottomBar extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final String taxPercentage;
  final String paymentMethod;
  final String paymentStatus;
  final bool hasItems;
  final VoidCallback onCompleteSale;

  const SaleSummaryBottomBar({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.taxPercentage,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.hasItems,
    required this.onCompleteSale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  '₦ ${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),

            // Discount row (if discount > 0)
            if (discount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    '- ₦ ${discount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],

            // Tax row (if tax > 0)
            if (tax > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tax ($taxPercentage%)',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    '₦ ${tax.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
            ],

            const Divider(color: Color(0xFFE2E8F0), height: 1),
            SizedBox(height: 8.h),

            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  '₦ ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            if (paymentMethod != 'Credit') ...[
              // Payment status indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Status',
                    style: TextStyle(
                      color: const Color(0xFF64748B),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: paymentStatus == 'Paid'
                          ? const Color(0xFFECFDF5)
                          : paymentStatus == 'Partial'
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      paymentStatus,
                      style: TextStyle(
                        color: paymentStatus == 'Paid'
                            ? const Color(0xFF059669)
                            : paymentStatus == 'Partial'
                                ? const Color(0xFFD97706)
                                : const Color(0xFFDC2626),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],

            // Complete Sale Button
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9F68), // Green complete button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                onPressed: !hasItems ? null : onCompleteSale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Complete Sale',
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
          ],
        ),
      ),
    );
  }
}
