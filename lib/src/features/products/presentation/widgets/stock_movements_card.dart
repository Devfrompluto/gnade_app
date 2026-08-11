import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class StockMovementsCard extends StatefulWidget {
  final Product product;

  const StockMovementsCard({super.key, required this.product});

  @override
  State<StockMovementsCard> createState() => _StockMovementsCardState();
}

class _StockMovementsCardState extends State<StockMovementsCard> {
  bool _isMovementsExpanded = false;
  bool _isBatchesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final unit = widget.product.unit.isNotEmpty ? widget.product.unit : 'pcs';
    final qty = widget.product.quantity.toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'History & records',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 12.h),

        // Product Batches Expandable Card — shows batch count
        _ProductBatchesCard(
          unit: unit,
          totalQty: qty,
          createdAt: widget.product.createdAt,
          isExpanded: _isBatchesExpanded,
          onToggle: () => setState(() => _isBatchesExpanded = !_isBatchesExpanded),
        ),
        SizedBox(height: 10.h),

        // Stock Movements Expandable Card
        _StockMovementsExpandableCard(
          unit: unit,
          totalQty: qty,
          createdAt: widget.product.createdAt,
          isExpanded: _isMovementsExpanded,
          onToggle: () => setState(() => _isMovementsExpanded = !_isMovementsExpanded),
        ),
      ],
    );
  }
}

// --- Product Batches Card ---

class _ProductBatchesCard extends StatelessWidget {
  final String unit;
  final String totalQty;
  final DateTime createdAt;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ProductBatchesCard({
    required this.unit,
    required this.totalQty,
    required this.createdAt,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(Icons.layers_outlined, color: const Color(0xFF1E40AF), size: 20.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Batches',
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '1 batch · $totalQty $unit total',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: _buildBatchItem(
                batchName: 'Initial Batch',
                date: DateFormat('dd MMM yyyy').format(createdAt),
                quantity: '$totalQty $unit',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBatchItem({
    required String batchName,
    required String date,
    required String quantity,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.inventory_2_outlined, color: const Color(0xFF1E40AF), size: 16.sp),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batchName,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
              Text(date, style: TextStyle(color: const Color(0xFF64748B), fontSize: 11.sp)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            quantity,
            style: TextStyle(
              color: const Color(0xFF1E40AF),
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Stock Movements Expandable Card ---

class _StockMovementsExpandableCard extends StatelessWidget {
  final String unit;
  final String totalQty;
  final DateTime createdAt;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _StockMovementsExpandableCard({
    required this.unit,
    required this.totalQty,
    required this.createdAt,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Icon(Icons.swap_vert_rounded, color: const Color(0xFF9333EA), size: 20.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Stock Movements',
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                children: [
                  _buildMovementItem(
                    title: 'Restock from supplier',
                    date: DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                    quantityChange: '+$totalQty $unit',
                    isAddition: true,
                  ),
                  SizedBox(height: 10.h),
                  _buildMovementItem(
                    title: 'Initial inventory creation',
                    date: DateFormat('dd MMM yyyy').format(createdAt),
                    quantityChange: 'Initial Batch',
                    isAddition: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMovementItem({
    required String title,
    required String date,
    required String quantityChange,
    required bool isAddition,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isAddition ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isAddition ? Icons.add_rounded : Icons.remove_rounded,
              color: isAddition ? const Color(0xFF166534) : const Color(0xFF991B1B),
              size: 16.sp,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
              Text(date, style: TextStyle(color: const Color(0xFF64748B), fontSize: 11.sp)),
            ],
          ),
        ),
        Text(
          quantityChange,
          style: TextStyle(
            color: isAddition ? const Color(0xFF166534) : const Color(0xFF991B1B),
            fontWeight: FontWeight.bold,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
