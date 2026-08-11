import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import '../providers/products_providers.dart';
import '../widgets/products_add_general_card.dart';
import '../widgets/products_add_pricing_card.dart';
import '../widgets/products_add_stock_card.dart';
import '../widgets/products_add_supplier_card.dart';
import '../widgets/products_add_bottom_actions.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellPriceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _lowStockController;
  late final TextEditingController _expiryDateController;

  String? _selectedCategory;
  late String _selectedUnit;
  DateTime? _expiryDate;
  SupplierMock? _selectedSupplier;
  
  bool _isLoading = false;
  double _profitMargin = 0;

  // Reason for stock edit
  String _selectedReason = 'Product information update';
  final _reasonNoteController = TextEditingController();
  static const List<String> _editReasonOptions = [
    'Product information update',
    'Inventory count adjustment',
    'Damaged / Broken stock',
    'Returned item',
    'Stolen / Lost stock',
    'Price correction',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _costPriceController = TextEditingController(text: widget.product.costPrice.toStringAsFixed(0));
    _sellPriceController = TextEditingController(text: widget.product.sellPrice.toStringAsFixed(0));
    _quantityController = TextEditingController(text: widget.product.quantity.toStringAsFixed(0));
    _lowStockController = TextEditingController(text: widget.product.lowStockAt.toStringAsFixed(0));
    
    _expiryDate = widget.product.expiryDate;
    _expiryDateController = TextEditingController(
      text: _expiryDate != null ? DateFormat('dd/MM/yyyy').format(_expiryDate!) : '',
    );

    _selectedCategory = widget.product.category;
    _selectedUnit = widget.product.unit;
    if (widget.product.supplier.isNotEmpty && widget.product.supplier != 'None') {
      _selectedSupplier = SupplierMock(
        id: widget.product.supplierId,
        name: widget.product.supplier,
        phone: '',
        supplyValue: '',
        debtAmount: '',
        purchases: const [],
      );
    }

    _calculateMargin();

    _costPriceController.addListener(_calculateMargin);
    _sellPriceController.addListener(_calculateMargin);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    _expiryDateController.dispose();
    _reasonNoteController.dispose();
    super.dispose();
  }

  void _calculateMargin() {
    final cost = double.tryParse(_costPriceController.text) ?? 0.0;
    final sell = double.tryParse(_sellPriceController.text) ?? 0.0;
    setState(() {
      _profitMargin = (cost > 0) ? (((sell - cost) / cost) * 100) : 0;
    });
  }

  void _generateSku() {
    setState(() => _skuController.text = 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}');
    showGlobalToast(message: 'Unique SKU generated!');
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // allow past expiry for edit
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showCategorySelectorSheet() {
    final newCategoryController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(categoriesProvider);

              return Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Category',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Add Category Container
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: newCategoryController,
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Create new category (e.g. Cosmetics)',
                                hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final name = newCategoryController.text.trim();
                              if (name.isNotEmpty) {
                                final res = await ref.read(categoriesProvider.notifier).addCategory(name);
                                if (res != null) {
                                  setState(() {
                                    _selectedCategory = res;
                                  });
                                  if (context.mounted) Navigator.pop(context);
                                  showGlobalToast(message: 'Category "$name" created & selected!');
                                } else {
                                  showGlobalToast(message: 'Failed to create category', status: 'error');
                                }
                              }
                            },
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Categories List
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 250.h),
                      child: categoriesAsync.when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            return const Center(child: Text('No categories found. Create one above!'));
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) => const Divider(color: Color(0xFFEFF6FF)),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = _selectedCategory == category;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  category,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Center(child: Text('Error loading categories')),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showSupplierSelectorSheet() {
    final newSupplierController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final suppliers = ref.watch(suppliersListProvider);

              return Container(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Supplier',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Add Supplier Container
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: newSupplierController,
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: 'Create new supplier (e.g. Promasidor)',
                                hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
                                isDense: true,
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              final name = newSupplierController.text.trim();
                              if (name.isNotEmpty) {
                                final newSupplier = await ref.read(suppliersListProvider.notifier).addSupplier(name, '');
                                if (newSupplier != null) {
                                  setState(() {
                                    _selectedSupplier = newSupplier;
                                  });
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    showGlobalToast(message: 'Supplier "$name" created & selected!');
                                  }
                                } else {
                                  showGlobalToast(message: 'Failed to create supplier.', status: 'error');
                                }
                              }
                            },
                            child: Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Suppliers List
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 250.h),
                      child: suppliers.isEmpty
                          ? const Center(child: Text('No suppliers found. Create one above!'))
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: suppliers.length,
                              separatorBuilder: (context, index) => const Divider(color: Color(0xFFEFF6FF)),
                              itemBuilder: (context, index) {
                                final supplier = suppliers[index];
                                final isSelected = _selectedSupplier?.id == supplier.id;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    supplier.name,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedSupplier = supplier;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _updateProduct() async {
    if (!await requireConnectivity()) return;
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (_selectedCategory == null) showGlobalToast(message: 'Select category', status: 'error');
      return;
    }
    setState(() => _isLoading = true);
    final res = await ref.read(productsListProvider.notifier).updateProduct(
      productId: widget.product.id,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      category: _selectedCategory!,
      costPrice: double.parse(_costPriceController.text),
      sellPrice: double.parse(_sellPriceController.text),
      quantity: double.parse(_quantityController.text),
      lowStockAt: double.parse(_lowStockController.text),
      unit: _selectedUnit,
      expiryDate: _expiryDate,
      supplierId: _selectedSupplier?.id,
      supplierName: _selectedSupplier?.name,
    );
    setState(() => _isLoading = false);
    if (res != null) {
      showGlobalToast(message: 'Product updated!');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Edit Product', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProductsAddGeneralCard(
                  nameController: _nameController,
                  skuController: _skuController,
                  selectedCategory: _selectedCategory,
                  selectedUnit: _selectedUnit,
                  onUnitChanged: (val) => setState(() => _selectedUnit = val),
                  onGenerateSku: _generateSku,
                  onCategoryTap: _showCategorySelectorSheet,
                ),
                SizedBox(height: 16.h),
                ProductsAddPricingCard(
                  costPriceController: _costPriceController,
                  sellPriceController: _sellPriceController,
                  profitMargin: _profitMargin,
                ),
                SizedBox(height: 16.h),
                ProductsAddStockCard(
                  quantityController: _quantityController,
                  lowStockController: _lowStockController,
                  expiryDateController: _expiryDateController,
                  onSelectExpiryDate: _selectExpiryDate,
                ),
                SizedBox(height: 16.h),
                ProductsAddSupplierCard(
                  selectedSupplier: _selectedSupplier,
                  onSupplierTap: _showSupplierSelectorSheet,
                ),
                SizedBox(height: 16.h),
                // Reason Box for stock changes
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, color: const Color(0xFF1E40AF), size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Reason for Changes',
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedReason,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                        items: _editReasonOptions
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF0F172A)))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedReason = val);
                        },
                      ),
                      SizedBox(height: 10.h),
                      AppTextField(
                        controller: _reasonNoteController,
                        hint: 'Additional note (optional)',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                ProductsAddBottomActions(
                  onSave: _updateProduct,
                  onCancel: () => Navigator.pop(context),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
