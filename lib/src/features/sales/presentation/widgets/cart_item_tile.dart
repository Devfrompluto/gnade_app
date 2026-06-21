import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';
import 'product_item_tile.dart';

class CartItemTile extends StatefulWidget {
  final ProductItemMock item;
  final double quantity;
  final double unitPrice; // Custom unit price or sell_price
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<CartItemTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  String _formatQty(double qty) {
    if (qty == qty.toInt()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatQty(widget.quantity));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      final textVal = double.tryParse(_controller.text);
      // If the text field is focused and empty or "0", do NOT overwrite it while the user is typing
      if (_focusNode.hasFocus && (_controller.text.isEmpty || _controller.text == '0' || _controller.text.endsWith('.'))) {
        return;
      }
      if (textVal != widget.quantity) {
        _controller.text = _formatQty(widget.quantity);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final val = double.tryParse(_controller.text) ?? 0.0;
      if (val <= 0) {
        setState(() {
          _controller.text = '1';
        });
        widget.onQuantityChanged(1);
      } else {
        setState(() {
          _controller.text = _formatQty(val);
        });
      }
    }
  }

  void _onInputChanged(String val) {
    if (val.isEmpty) {
      widget.onQuantityChanged(1);
      return;
    }
    final parsed = double.tryParse(val);
    if (parsed != null) {
      if (parsed <= 0) {
        widget.onQuantityChanged(1);
      } else {
        widget.onQuantityChanged(parsed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.unitPrice * widget.quantity;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title & Remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.item.name,
                  style: TextStyle(
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5.sp,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  Icons.close_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Row 2: Price/unit
          Text(
            '₦ ${widget.unitPrice.toStringAsFixed(0)} / unit',
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),

          // Row 3: Subtotal & Quantity controls capsule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₦ ${subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                ),
              ),

              // Quantity Capsule
              Container(
                height: 30.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // soft blue background
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.quantity > 1) {
                          widget.onQuantityChanged(widget.quantity - 1);
                        }
                      },
                      child: Container(
                        width: 32.w,
                        height: 30.h,
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            Icons.remove_rounded,
                            color: const Color(0xFF1E40AF),
                            size: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36.w,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: _onInputChanged,
                        decoration: const InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onQuantityChanged(widget.quantity + 1);
                      },
                      child: Container(
                        width: 32.w,
                        height: 30.h,
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: const Color(0xFF1E40AF),
                            size: 15.sp,
                          ),
                        ),
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
