import '../core/errors/failure.dart';
import '../models/analytics_summary_model.dart';
import '../services/analytics_service.dart';

class AnalyticsRepository {
  final AnalyticsService _service;

  AnalyticsRepository({AnalyticsService? service}) : _service = service ?? AnalyticsService();

  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _service.getAnalyticsSummary(
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
