import '../services/tax_service.dart';

class TaxRepository {
  final TaxService _service;

  TaxRepository({TaxService? service}) : _service = service ?? TaxService();

  TaxBreakdown calculateTax({
    required double taxableAmount,
    double taxPercentage = 18.0,
  }) {
    return _service.calculateTax(taxableAmount: taxableAmount, taxPercentage: taxPercentage);
  }
}
