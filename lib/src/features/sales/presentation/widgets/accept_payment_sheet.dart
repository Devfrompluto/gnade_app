import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/sales_providers.dart';

class AcceptPaymentSheet extends ConsumerStatefulWidget {
  final Sale sale;

  const AcceptPaymentSheet({super.key, required this.sale});

  @override
  ConsumerState<AcceptPaymentSheet> createState() => _AcceptPaymentSheetState();
}

class _AcceptPaymentSheetState extends ConsumerState<AcceptPaymentSheet> {
  final _amountController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String _selectedPaymentMethod = 'Cash';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = const [
    {'name': 'Cash', 'icon': Icons.payments_outlined},
    {'name': 'Transfer', 'icon': Icons.account_balance_outlined},
    {'name': 'Credit', 'icon': Icons.credit_card_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _enteredAmount => double.tryParse(_amountController.text) ?? 0.0;
  bool get _isSettledInFull =>
      _enteredAmount >= widget.sale.balanceDue && widget.sale.balanceDue > 0;

  Future<void> _selectPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _paymentDate = picked);
    }
  }

  Future<void> _confirmPayment() async {
    if (_enteredAmount <= 0) {
      showGlobalToast(
          message: 'Please enter a valid payment amount', status: 'error');
      return;
    }

    setState(() => _isLoading = true);

    final repo = ref.read(salesRepositoryProvider);
    final result = await repo.recordPayment(
      saleId: widget.sale.id,
      paymentAmount: _enteredAmount,
      paymentMethod: _selectedPaymentMethod,
      paymentDate: _paymentDate,
    );

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        showGlobalToast(
            message: 'Failed to record payment: ${failure.message}',
            status: 'error');
      },
      (updatedSale) {
        ref.invalidate(saleDetailsProvider(widget.sale.id));
        ref.invalidate(salesHistoryProvider);
        ref.invalidate(salesSummaryProvider);
        showGlobalToast(message: 'Payment recorded successfully!');
        if (mounted) Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceDueFormatted =
        NumberFormat('#,##0.00').format(widget.sale.balanceDue);
    final isToday = DateUtils.isSameDay(_paymentDate, DateTime.now());
    final formattedDateStr = isToday
        ? 'Today, ${DateFormat('MMM dd').format(_paymentDate)}'
        : DateFormat('E, MMM dd, yyyy').format(_paymentDate);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 14.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              // Center(
              //   child: Container(
              //     width: 36.w,
              //     height: 4.h,
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFCBD5E1),
              //       borderRadius: BorderRadius.circular(2.r),
              //     ),
              //   ),
              // ),
              SizedBox(height: 16.h),

              // Title Header (Money Icon + Accept Payment & Subtitle Order #)
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFDBEAFE), // Royal blue light container
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.payments_rounded,
                        color: const Color(0xFF1E40AF),
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Accept Payment',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Order #${widget.sale.invoiceNo}',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Balance Due Container (Amber/Orange design matching Image 1)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Amber-50
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFFED7AA)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Balance Due',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    Text(
                      '₦ $balanceDueFormatted',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Amount Input Field & Pills
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  prefixText: '₦ ',
                  prefixStyle: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E40AF), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide:
                        const BorderSide(color: Color(0xFF1E40AF), width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Quick Amount Pills (Full amount & Half)
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      _amountController.text =
                          widget.sale.balanceDue.toStringAsFixed(0);
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Full amount',
                        style: TextStyle(
                          color: const Color(0xFF1E40AF),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () {
                      final half = (widget.sale.balanceDue / 2);
                      _amountController.text = half.toStringAsFixed(0);
                    },
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Half',
                        style: TextStyle(
                          color: const Color(0xFF1E40AF),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Settlement Status Pill
              if (_isSettledInFull) ...[
                Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: const Color(0xFF1E40AF), size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'This payment settles the sale in full',
                        style: TextStyle(
                          color: const Color(0xFF1E40AF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
              ],

              // Payment Date Selector
              Text(
                'Payment date',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        color: const Color(0xFF64748B), size: 18.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        formattedDateStr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _selectPaymentDate,
                      child: Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Payment Method Choices
              Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: _paymentMethods.map((method) {
                  final name = method['name'] as String;
                  final icon = method['icon'] as IconData;
                  final isSelected = _selectedPaymentMethod == name;

                  return InkWell(
                    onTap: () => setState(() => _selectedPaymentMethod = name),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 18.sp,
                            color: isSelected
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF1E40AF)
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // Bottom Actions: Cancel & Confirm Payment
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E40AF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: const Color(0xFF1E40AF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Confirm Payment',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
