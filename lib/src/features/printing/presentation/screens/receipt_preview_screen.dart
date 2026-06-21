import 'package:gnade_app/src/imports/imports.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final ReceiptData? receiptData;

  const ReceiptPreviewScreen({
    super.key,
    this.receiptData,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  // Toggle between 'POS' and 'A4'
  String _selectedLayout = 'POS';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    // Use passed data or construct a dummy fallback matching the mockup
    final data = widget.receiptData ??
        ReceiptData(
          businessName: 'GNADE MULTICONCEPT',
          businessAddress: '123 Market Street, Victoria Island, Lagos',
          businessPhone: '+234 800 123 4567',
          businessEmail: 'contact@gnademulticoncept.com',
          invoiceNo: 'INV-2023-0891',
          dateTime: DateTime.now(),
          customerName: 'Musa Abubakar',
          customerType: 'Retail Customer',
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
            ReceiptItem(
              name: 'Espresso Single',
              quantity: 1,
              unitPrice: 2500,
              total: 2500,
            ),
          ],
          subtotal: 22000,
          tax: 1650,
          total: 23650,
          amountPaid: 23650,
          paymentMethod: 'Cash',
          paymentStatus: 'Paid',
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light background for contrast
      appBar: AppCustomAppBar(
        title: 'Receipt Preview',
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurface,
              size: 20.sp,
            ),
            onPressed: () {
              showGlobalToast(message: 'More options coming soon!');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header Selector (Segmented Switch) ──────────────────────────
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    // POS Size Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLayout = 'POS';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedLayout == 'POS'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: _selectedLayout == 'POS'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'POS Receipt',
                              style: TextStyle(
                                color: _selectedLayout == 'POS'
                                    ? const Color(0xFF1E40AF)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // A4 Version Option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLayout = 'A4';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedLayout == 'A4'
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: _selectedLayout == 'A4'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'A4 Version',
                              style: TextStyle(
                                color: _selectedLayout == 'A4'
                                    ? const Color(0xFF1E40AF)
                                    : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Scrollable Preview Canvas ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedLayout == 'POS'
                        ? POSReceiptPreview(key: const ValueKey('pos_preview'), data: data)
                        : A4ReceiptPreview(key: const ValueKey('a4_preview'), data: data),
                  ),
                ),
              ),
            ),

            // ─── Footer Action Buttons ──────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selectedLayout == 'POS'
                    ? const POSReceiptActions(key: ValueKey('pos_actions'))
                    : A4ReceiptActions(key: const ValueKey('a4_actions'), data: data),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
