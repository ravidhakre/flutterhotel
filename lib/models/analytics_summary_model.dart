class AnalyticsSummaryModel {
  final int totalBookings;
  final int confirmedBookings;
  final int cancelledBookings;
  final int todayCheckIns;
  final int todayCheckOuts;
  final double occupancyRate;
  final double grossBookingValue;
  final double collectedRevenue;
  final double pendingAmount;
  final double refundsAmount;
  final double netRevenue;
  final double adr;
  final double revpar;
  final double alos;
  final double cancellationRate;

  AnalyticsSummaryModel({
    required this.totalBookings,
    required this.confirmedBookings,
    required this.cancelledBookings,
    required this.todayCheckIns,
    required this.todayCheckOuts,
    required this.occupancyRate,
    required this.grossBookingValue,
    required this.collectedRevenue,
    required this.pendingAmount,
    required this.refundsAmount,
    required this.netRevenue,
    required this.adr,
    required this.revpar,
    required this.alos,
    required this.cancellationRate,
  });
}
