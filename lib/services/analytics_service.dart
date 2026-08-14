import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/analytics_summary_model.dart';
import '../models/booking_model.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Calculate real-data executive KPIs for date range and property filter
  Future<AnalyticsSummaryModel> getAnalyticsSummary({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      Query query = _firestore.collection(FirebaseConstants.bookingsCollection);
      if (propertyId != 'All') {
        query = query.where('propertyId', isEqualTo: propertyId);
      }

      final snapshot = await query.get();
      final allBookings = snapshot.docs
          .map((d) => BookingModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .where((b) => b.createdAt.isAfter(start) && b.createdAt.isBefore(end))
          .toList();

      int totalBookings = allBookings.length;
      int confirmedBookings = 0;
      int cancelledBookings = 0;
      int todayCheckIns = 0;
      int todayCheckOuts = 0;

      double grossBookingValue = 0.0;
      double collectedRevenue = 0.0;
      double pendingAmount = 0.0;
      double roomRevenueTotal = 0.0;
      int totalNightsSold = 0;

      final now = DateTime.now();

      for (final b in allBookings) {
        grossBookingValue += b.totalAmount;
        collectedRevenue += b.paidAmount;
        pendingAmount += b.remainingAmount;

        if (b.bookingStatus == 'confirmed' || b.bookingStatus == 'checkedIn' || b.bookingStatus == 'checkedOut') {
          confirmedBookings++;
          roomRevenueTotal += b.roomPrice;
          totalNightsSold += b.nights;
        }

        if (b.bookingStatus == 'cancelled') cancelledBookings++;

        if (b.checkIn.year == now.year && b.checkIn.month == now.month && b.checkIn.day == now.day) {
          todayCheckIns++;
        }
        if (b.checkOut.year == now.year && b.checkOut.month == now.month && b.checkOut.day == now.day) {
          todayCheckOuts++;
        }
      }

      // Fetch total physical rooms for occupancy & RevPAR calculation
      Query roomsQuery = _firestore.collection(FirebaseConstants.roomsCollection);
      if (propertyId != 'All') {
        roomsQuery = roomsQuery.where('propertyId', isEqualTo: propertyId);
      }
      final roomsSnapshot = await roomsQuery.get();
      int totalPhysicalRooms = roomsSnapshot.docs.isEmpty ? 10 : roomsSnapshot.docs.length;

      final daysInRange = (end.difference(start).inDays + 1);
      final totalAvailableRoomNights = totalPhysicalRooms * daysInRange;

      // ADR = Room Revenue / Rooms Sold
      final adr = totalNightsSold > 0 ? roomRevenueTotal / totalNightsSold : 0.0;

      // RevPAR = Room Revenue / Available Room Nights
      final revpar = totalAvailableRoomNights > 0 ? roomRevenueTotal / totalAvailableRoomNights : 0.0;

      // Occupancy % = (Occupied Nights / Available Nights) * 100
      final occupancyRate = totalAvailableRoomNights > 0 ? (totalNightsSold / totalAvailableRoomNights) * 100.0 : 0.0;

      // ALOS = Total Nights / Completed Stays
      final alos = confirmedBookings > 0 ? totalNightsSold / confirmedBookings : 0.0;

      final cancellationRate = totalBookings > 0 ? (cancelledBookings / totalBookings) * 100.0 : 0.0;

      return AnalyticsSummaryModel(
        totalBookings: totalBookings,
        confirmedBookings: confirmedBookings,
        cancelledBookings: cancelledBookings,
        todayCheckIns: todayCheckIns,
        todayCheckOuts: todayCheckOuts,
        occupancyRate: occupancyRate,
        grossBookingValue: grossBookingValue,
        collectedRevenue: collectedRevenue,
        pendingAmount: pendingAmount,
        refundsAmount: 0.0,
        netRevenue: collectedRevenue,
        adr: adr,
        revpar: revpar,
        alos: alos,
        cancellationRate: cancellationRate,
      );
    } catch (e) {
      throw DatabaseException('Failed to calculate analytics summary: $e');
    }
  }
}
