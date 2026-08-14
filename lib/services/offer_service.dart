import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/offer_model.dart';
import 'audit_service.dart';

class OfferService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Create or update offer
  Future<void> saveOffer(OfferModel offer) async {
    try {
      final docRef = offer.offerId.isNotEmpty
          ? _firestore.collection('offers').doc(offer.offerId)
          : _firestore.collection('offers').doc();

      final newOffer = OfferModel(
        offerId: docRef.id,
        name: offer.name,
        description: offer.description,
        offerType: offer.offerType,
        discountType: offer.discountType,
        discountValue: offer.discountValue,
        propertyIds: offer.propertyIds,
        roomTypeIds: offer.roomTypeIds,
        startDate: offer.startDate,
        endDate: offer.endDate,
        minimumNights: offer.minimumNights,
        maximumNights: offer.maximumNights,
        minimumBookingAmount: offer.minimumBookingAmount,
        newUserOnly: offer.newUserOnly,
        existingUserOnly: offer.existingUserOnly,
        weekendOnly: offer.weekendOnly,
        weekdayOnly: offer.weekdayOnly,
        usageLimit: offer.usageLimit,
        perUserLimit: offer.perUserLimit,
        priority: offer.priority,
        allowStacking: offer.allowStacking,
        status: offer.status,
        createdBy: offer.createdBy,
      );

      await docRef.set(newOffer.toMap(), SetOptions(merge: true));

      await _auditService.logAction(
        action: 'OFFER_SAVED',
        module: 'COMMERCIAL',
        recordId: docRef.id,
        performedBy: offer.createdBy,
        newData: newOffer.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to save offer: $e');
    }
  }

  /// Get active offers for property & room type
  Future<List<OfferModel>> getApplicableOffers({
    required String propertyId,
    required String roomTypeId,
    required DateTime date,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('offers')
          .where('status', isEqualTo: 'active')
          .get();

      final allOffers = snapshot.docs.map((d) => OfferModel.fromMap(d.data(), d.id)).toList();

      return allOffers.where((offer) {
        final matchesProp = offer.propertyIds.isEmpty || offer.propertyIds.contains(propertyId);
        final matchesRoom = offer.roomTypeIds.isEmpty || offer.roomTypeIds.contains(roomTypeId);
        final matchesDate = date.isAfter(offer.startDate) && date.isBefore(offer.endDate.add(const Duration(days: 1)));

        return matchesProp && matchesRoom && matchesDate;
      }).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
    } catch (e) {
      throw DatabaseException('Failed to fetch applicable offers: $e');
    }
  }
}
