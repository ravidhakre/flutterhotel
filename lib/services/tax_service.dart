class TaxBreakdown {
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double totalTaxRate;
  final double totalTaxAmount;

  TaxBreakdown({
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.totalTaxRate,
    required this.totalTaxAmount,
  });
}

class TaxService {
  /// Calculate GST tax breakdown (CGST + SGST) from taxable subtotal
  TaxBreakdown calculateTax({
    required double taxableAmount,
    double taxPercentage = 18.0,
    bool isIntraState = true,
  }) {
    if (taxableAmount <= 0) {
      return TaxBreakdown(
        cgstRate: 0,
        cgstAmount: 0,
        sgstRate: 0,
        sgstAmount: 0,
        totalTaxRate: 0,
        totalTaxAmount: 0,
      );
    }

    final totalTaxAmount = (taxableAmount * taxPercentage) / 100.0;
    final halfRate = taxPercentage / 2.0;
    final halfAmount = totalTaxAmount / 2.0;

    return TaxBreakdown(
      cgstRate: isIntraState ? halfRate : 0.0,
      cgstAmount: isIntraState ? halfAmount : 0.0,
      sgstRate: isIntraState ? halfRate : 0.0,
      sgstAmount: isIntraState ? halfAmount : 0.0,
      totalTaxRate: taxPercentage,
      totalTaxAmount: totalTaxAmount,
    );
  }
}
