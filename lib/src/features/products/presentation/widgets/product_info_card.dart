import 'package:gnade_app/src/imports/core_imports.dart';
import 'package:gnade_app/src/imports/packages_imports.dart';

class ProductInfoCard extends StatelessWidget {
  final Product product;
  final String unit;
  final bool isStaff;

  const ProductInfoCard({
    super.key,
    required this.product,
    required this.unit,
    required this.isStaff,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product information',
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow('Base unit', unit),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Category', product.category),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            'Half unit price',
            product.hasHalfUnit
                ? '₦ ${NumberFormat('#,##0').format(product.halfUnitPrice!)}'
                : 'Not set',
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow(
            'Retail price',
            product.hasRetailPrice
                ? '₦ ${NumberFormat('#,##0').format(product.retailPrice!)}'
                : 'Not set',
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Selling Price', '₦ ${NumberFormat('#,##0').format(product.sellPrice)}'),
          if (!isStaff) ...[
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            _buildInfoRow('Cost Price', '₦ ${NumberFormat('#,##0').format(product.costPrice)}'),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
            _buildInfoRow(
              'Supplier',
              product.supplier,
              isLink: product.supplier != 'None',
              onTap: product.supplier != 'None'
                  ? () => context.push('/products/supplier/${product.supplierId}')
                  : null,
            ),
          ],
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Low stock alert', '${product.lowStockAt.toStringAsFixed(0)} $unit'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Added', DateFormat('dd MMM yyyy').format(product.createdAt)),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _buildInfoRow('Last updated', DateFormat('dd MMM yyyy').format(product.displayUpdatedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF64748B),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4.r),
          child: Text(
            value,
            style: TextStyle(
              color: isLink ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              decoration: isLink ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
