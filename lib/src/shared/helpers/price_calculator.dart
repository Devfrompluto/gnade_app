/// Price calculation utility for multi-price & half-unit quantity feature.
///
/// Rules:
/// - Wholesale unit price = wholesalePrice
/// - Retail unit price = retailPrice (if set, else wholesalePrice)
/// - Full units: floor(qty) × unitPrice
/// - Half unit (.5): halfUnitPrice (if set, else 0.5 × unitPrice)
class PriceCalculator {
  PriceCalculator._();

  /// Calculates the correct line total for a sale item (supports both Wholesale & Retail with .5 quantity).
  static double calculateLineTotal({
    required double quantity,
    required double wholesalePrice,
    required double? halfUnitPrice,
    required double? retailPrice,
    required String priceType,
  }) {
    // Tolerant floating-point decimal check for .5
    final double remainder = (quantity % 1).abs();
    final bool hasHalf = (remainder - 0.5).abs() < 0.05;

    // Unit price depending on priceType
    final double unitPrice = (priceType == 'retail' && retailPrice != null && retailPrice > 0)
        ? retailPrice
        : wholesalePrice;

    // Full whole units count
    final double fullUnits = quantity.floorToDouble();

    // Effective half unit price: custom halfUnitPrice if set, else half of unitPrice
    final double effectiveHalfPrice = (halfUnitPrice != null && halfUnitPrice > 0)
        ? halfUnitPrice
        : (unitPrice / 2);

    final double fullTotal = (hasHalf ? fullUnits : quantity) * unitPrice;
    final double halfTotal = hasHalf ? effectiveHalfPrice : 0.0;

    return fullTotal + halfTotal;
  }
}
