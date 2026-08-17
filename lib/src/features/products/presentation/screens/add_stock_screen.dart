import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';

class AddStockScreen extends ConsumerStatefulWidget {
  final Product product;

  const AddStockScreen({super.key, required this.product});

  @override
  ConsumerState<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends ConsumerState<AddStockScreen> {
  final _qtyController = TextEditingController(text: '1');
  late final TextEditingController _costController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _halfUnitPriceController;
  late final TextEditingController _retailPriceController;

  bool _updateSellingPrice = false;
  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController(
      text: widget.product.costPrice > 0 ? widget.product.costPrice.toStringAsFixed(0) : '0',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product.sellPrice > 0 ? widget.product.sellPrice.toStringAsFixed(0) : '0',
    );
    _halfUnitPriceController = TextEditingController(
      text: widget.product.halfUnitPrice != null && widget.product.halfUnitPrice! > 0
          ? widget.product.halfUnitPrice!.toStringAsFixed(0)
          : '',
    );
    _retailPriceController = TextEditingController(
      text: widget.product.retailPrice != null && widget.product.retailPrice! > 0
          ? widget.product.retailPrice!.toStringAsFixed(0)
          : '',
    );
    _qtyController.addListener(() => setState(() {}));
    _costController.addListener(() => setState(() {}));
    _sellingPriceController.addListener(() => setState(() {}));
    _halfUnitPriceController.addListener(() => setState(() {}));
    _retailPriceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    _sellingPriceController.dispose();
    _halfUnitPriceController.dispose();
    _retailPriceController.dispose();
    super.dispose();
  }

  double get _subtotal {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0;
    return qty * cost;
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _addStock() async {
    final addedQty = double.tryParse(_qtyController.text) ?? 0;
    if (addedQty <= 0) {
      showGlobalToast(message: 'Enter a valid stock quantity', status: 'error');
      return;
    }

    setState(() => _isLoading = true);

    final newCost = double.tryParse(_costController.text) ?? widget.product.costPrice;
    final newSelling = _updateSellingPrice
        ? (double.tryParse(_sellingPriceController.text) ?? widget.product.sellPrice)
        : widget.product.sellPrice;
    final newHalfUnit = _updateSellingPrice
        ? (_halfUnitPriceController.text.trim().isNotEmpty
            ? double.tryParse(_halfUnitPriceController.text.trim())
            : null)
        : widget.product.halfUnitPrice;
    final newRetail = _updateSellingPrice
        ? (_retailPriceController.text.trim().isNotEmpty
            ? double.tryParse(_retailPriceController.text.trim())
            : null)
        : widget.product.retailPrice;
    final newTotalQty = widget.product.quantity + addedQty;

    await ref.read(productsListProvider.notifier).updateProduct(
      productId: widget.product.id,
      name: widget.product.name,
      sku: widget.product.sku,
      category: widget.product.category,
      costPrice: newCost,
      sellPrice: newSelling,
      quantity: newTotalQty,
      lowStockAt: widget.product.lowStockAt,
      unit: widget.product.unit,
      expiryDate: _expiryDate ?? widget.product.expiryDate,
      supplierId: widget.product.supplierId,
      supplierName: widget.product.supplier,
      halfUnitPrice: newHalfUnit,
      retailPrice: newRetail,
    );

    setState(() => _isLoading = false);
    showGlobalToast(message: 'Added ${addedQty.toStringAsFixed(0)} ${widget.product.unit} to stock!');
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.product.unit.isNotEmpty ? widget.product.unit : 'pcs';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppCustomAppBar(
        title: 'Add Stock',
        onBackPressed: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AddStockProductHeader(product: widget.product, unit: unit),
            SizedBox(height: 16.h),
            _AddStockQuantityCard(
              unit: unit,
              qtyController: _qtyController,
              costController: _costController,
            ),
            SizedBox(height: 12.h),
            _AddStockSubtotalCard(subtotal: _subtotal),
            SizedBox(height: 12.h),
            _AddStockSellingPriceToggle(
              product: widget.product,
              updateSellingPrice: _updateSellingPrice,
              sellingPriceController: _sellingPriceController,
              halfUnitPriceController: _halfUnitPriceController,
              retailPriceController: _retailPriceController,
              onToggle: (val) => setState(() => _updateSellingPrice = val),
            ),
            SizedBox(height: 12.h),
            _AddStockExpiryDateRow(
              expiryDate: _expiryDate,
              onTap: _selectExpiryDate,
            ),
            SizedBox(height: 24.h),
            AppButton(
              label: 'Add Stock',
              color: const Color(0xFF1E40AF),
              isFullWidth: true,
              isLoading: _isLoading,
              onPressed: _addStock,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Extracted Child Widgets ---

class _AddStockProductHeader extends StatelessWidget {
  final Product product;
  final String unit;

  const _AddStockProductHeader({required this.product, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                Icons.move_to_inbox_rounded,
                color: const Color(0xFF1E40AF),
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Current stock: ${product.quantity.toStringAsFixed(0)} $unit',
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
    );
  }
}

class _AddStockQuantityCard extends StatelessWidget {
  final String unit;
  final TextEditingController qtyController;
  final TextEditingController costController;

  const _AddStockQuantityCard({
    required this.unit,
    required this.qtyController,
    required this.costController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets_outlined, color: const Color(0xFF1E40AF), size: 20.sp),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    'Stock is kept in $unit',
                    style: TextStyle(color: const Color(0xFF64748B), fontSize: 12.sp),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        suffixText: unit,
                        suffixStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cost per $unit', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
                    SizedBox(height: 4.h),
                    TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        prefixText: '₦ ',
                        prefixStyle: TextStyle(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14.sp),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddStockSubtotalCard extends StatelessWidget {
  final double subtotal;

  const _AddStockSubtotalCard({required this.subtotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Subtotal', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF64748B))),
          Text(
            '₦ ${NumberFormat('#,##0').format(subtotal)}',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E40AF)),
          ),
        ],
      ),
    );
  }
}

class _AddStockSellingPriceToggle extends StatelessWidget {
  final Product product;
  final bool updateSellingPrice;
  final TextEditingController sellingPriceController;
  final TextEditingController halfUnitPriceController;
  final TextEditingController retailPriceController;
  final ValueChanged<bool> onToggle;

  const _AddStockSellingPriceToggle({
    required this.product,
    required this.updateSellingPrice,
    required this.sellingPriceController,
    required this.halfUnitPriceController,
    required this.retailPriceController,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sell_outlined, color: const Color(0xFF64748B), size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update selling prices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF0F172A))),
                    Text('Optional. Existing prices stay unchanged when this is off.', style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Switch(
                value: updateSellingPrice,
                activeTrackColor: const Color(0xFF1E40AF),
                onChanged: onToggle,
              ),
            ],
          ),
          if (updateSellingPrice) ...[
            SizedBox(height: 10.h),
            AppTextField(
              controller: sellingPriceController,
              label: 'New Selling Price (₦)',
              keyboardType: TextInputType.number,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 12.w, top: 12.h),
                child: Text('₦ ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ),
            ),
            _buildPriceDifferenceHint(
              currentPrice: product.sellPrice,
              newPriceText: sellingPriceController.text,
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: halfUnitPriceController,
                        label: 'New Half Unit Price (₦)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.w, top: 12.h),
                          child: Text('₦ ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        ),
                      ),
                      _buildPriceDifferenceHint(
                        currentPrice: product.halfUnitPrice,
                        newPriceText: halfUnitPriceController.text,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: retailPriceController,
                        label: 'New Retail Price (₦)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 12.w, top: 12.h),
                          child: Text('₦ ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        ),
                      ),
                      _buildPriceDifferenceHint(
                        currentPrice: product.retailPrice,
                        newPriceText: retailPriceController.text,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceDifferenceHint({
    required double? currentPrice,
    required String newPriceText,
  }) {
    final newPrice = double.tryParse(newPriceText.trim());

    if (currentPrice == null || currentPrice <= 0) {
      if (newPrice != null && newPrice > 0) {
        return Padding(
          padding: EdgeInsets.only(top: 4.h, left: 4.w),
          child: Text(
            'New price: ₦${NumberFormat('#,##0').format(newPrice)}',
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF166534), fontWeight: FontWeight.w600),
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.only(top: 4.h, left: 4.w),
        child: Text(
          'Currently not set',
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF94A3B8)),
        ),
      );
    }

    if (newPrice == null || newPrice == currentPrice) {
      return Padding(
        padding: EdgeInsets.only(top: 4.h, left: 4.w),
        child: Text(
          'Current: ₦${NumberFormat('#,##0').format(currentPrice)} (no change)',
          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
        ),
      );
    }

    final diff = newPrice - currentPrice;
    final isIncrease = diff > 0;
    final diffStr = NumberFormat('#,##0').format(diff.abs());
    final color = isIncrease ? const Color(0xFF166534) : const Color(0xFF991B1B);
    final bg = isIncrease ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);
    final icon = isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Padding(
      padding: EdgeInsets.only(top: 4.h, left: 4.w),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4.w,
        children: [
          Text(
            'Current: ₦${NumberFormat('#,##0').format(currentPrice)}',
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 10.sp, color: color),
                SizedBox(width: 2.w),
                Text(
                  '${isIncrease ? '+' : '-'}₦$diffStr',
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStockExpiryDateRow extends StatelessWidget {
  final DateTime? expiryDate;
  final VoidCallback onTap;

  const _AddStockExpiryDateRow({required this.expiryDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: const Color(0xFF64748B), size: 18.sp),
            SizedBox(width: 10.w),
            Text(
              expiryDate != null
                  ? 'Expires: ${DateFormat('dd MMM yyyy').format(expiryDate!)}'
                  : 'Set expiry date (optional)',
              style: TextStyle(
                color: expiryDate != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                fontSize: 13.sp,
                fontWeight: expiryDate != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
