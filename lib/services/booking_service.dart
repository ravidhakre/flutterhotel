import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../core/utils/logger.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_model.dart';
import '../models/property_model.dart';
import '../models/reservation_allocation_model.dart';
import '../models/room_type_model.dart';
import 'availability_service.dart';
import 'booking_event_service.dart';
import 'pricing_service.dart';
import 'reservation_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AvailabilityService _availabilityService = AvailabilityService();
  final PricingService _pricingService = PricingService();
  final ReservationService _reservationService = ReservationService();
  final BookingEventService _eventService = BookingEventService();

  /// Server-Authoritative Temporary Booking Hold Transaction (Double-Booking Prevention)
  /// Uses Firestore Transaction to atomically check availability and hold inventory.
  Future<BookingModel> createBookingHoldTransaction({
    required String userId,
    required String propertyId,
    required String roomTypeId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int adults,
    required int children,
    required int rooms,
    required Map<String, dynamic> guestDetails,
    int holdDurationMinutes = 10,
    String source = 'website',
  }) async {
    try {
      AppLogger.log('Starting Atomic Booking Hold Transaction for user $userId...');

      // 1. Server-side Property & Room Type fetching & validation
      final propDoc = await _firestore.collection(FirebaseConstants.propertiesCollection).doc(propertyId).get();
      if (!propDoc.exists) throw DatabaseException('Selected property not found');
      final property = PropertyModel.fromMap(propDoc.data()!, propDoc.id);

      final rtDoc = await _firestore.collection(FirebaseConstants.roomTypesCollection).doc(roomTypeId).get();
      if (!rtDoc.exists) throw DatabaseException('Selected room type not found');
      final roomType = RoomTypeModel.fromMap(rtDoc.data()!, rtDoc.id);

      // 2. Capacity Validation
      if (adults > (roomType.maxAdults * rooms)) {
        throw DatabaseException('Adult count exceeds max capacity of ${roomType.maxAdults * rooms}.');
      }

      // 3. Recalculate Prices Server-Side (Price Manipulation Protection)
      final pricing = _pricingService.calculatePrice(
        property: property,
        roomType: roomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
        adults: adults,
        children: children,
      );

      final humanBookingId = BookingModel.generateBookingId();
      final holdExpiresAt = DateTime.now().add(Duration(minutes: holdDurationMinutes));

      // 4. ATOMIC FIRESTORE TRANSACTION FOR DOUBLE-BOOKING PREVENTION
      await _firestore.runTransaction((transaction) async {
        // Double-check real-time availability inside transaction
        final availableRooms = await _availabilityService.getAvailableRooms(
          propertyId: propertyId,
          roomTypeId: roomTypeId,
          checkIn: checkIn,
          checkOut: checkOut,
        );

        if (availableRooms.length < rooms) {
          throw DatabaseException(
            'Inventory sold out! Only ${availableRooms.length} room(s) available for these dates.',
            code: 'INVENTORY_SOLD_OUT',
          );
        }

        final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(humanBookingId);

        final newBooking = BookingModel(
          bookingId: humanBookingId,
          userId: userId,
          propertyId: propertyId,
          roomTypeId: roomTypeId,
          checkIn: checkIn,
          checkOut: checkOut,
          nights: checkOut.difference(checkIn).inDays,
          adults: adults,
          children: children,
          rooms: rooms,
          guestDetails: guestDetails,
          roomPrice: pricing.roomPrice,
          nightlyRates: pricing.nightlyRates,
          extraGuestCharges: pricing.extraGuestCharges,
          tax: pricing.taxAmount,
          totalAmount: pricing.totalAmount,
          remainingAmount: pricing.totalAmount,
          paymentStatus: 'pending',
          bookingStatus: 'paymentPending',
          holdStatus: 'active',
          holdExpiresAt: holdExpiresAt,
          source: source,
        );

        transaction.set(bookingRef, newBooking.toMap());
      });

      // 5. Create Nightly Allocations
      final nights = checkOut.difference(checkIn).inDays;
      final allocations = <ReservationAllocationModel>[];

      for (int i = 0; i < nights; i++) {
        final nightDate = checkIn.add(Duration(days: i));
        for (int r = 0; r < rooms; r++) {
          final allocRef = _firestore.collection('reservationAllocations').doc();
          allocations.add(ReservationAllocationModel(
            allocationId: allocRef.id,
            bookingId: humanBookingId,
            propertyId: propertyId,
            roomTypeId: roomTypeId,
            date: nightDate,
            status: 'held',
          ));
        }
      }
      await _reservationService.createAllocations(allocations);

      // 6. Log Timeline Event
      await _eventService.logEvent(
        bookingId: humanBookingId,
        eventType: 'paymentPending',
        description: 'Temporary reservation hold created. Expires in $holdDurationMinutes minutes.',
        performedBy: userId,
        performedByRole: 'guest',
      );

      final createdDoc = await _firestore.collection(FirebaseConstants.bookingsCollection).doc(humanBookingId).get();
      return BookingModel.fromMap(createdDoc.data()!, humanBookingId);
    } catch (e) {
      throw DatabaseException('Booking creation failed: $e');
    }
  }

  /// Confirm booking after verified payment
  Future<void> confirmBooking(String bookingId, {required String paymentId, required String performedBy}) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final doc = await bookingRef.get();
      if (!doc.exists) throw DatabaseException('Booking not found');

      final current = BookingModel.fromMap(doc.data()!, bookingId);

      await bookingRef.update({
        'paymentStatus': 'success',
        'bookingStatus': 'confirmed',
        'holdStatus': 'released',
        'paidAmount': current.totalAmount,
        'remainingAmount': 0.0,
        'confirmedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _eventService.logEvent(
        bookingId: bookingId,
        eventType: 'bookingConfirmed',
        description: 'Payment verified successfully ($paymentId). Booking confirmed.',
        performedBy: performedBy,
        performedByRole: 'admin',
      );
    } catch (e) {
      throw DatabaseException('Failed to confirm booking: $e');
    }
  }

  /// Release expired booking hold
  Future<void> expireBookingHold(String bookingId) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final doc = await bookingRef.get();
      if (!doc.exists) return;

      if (doc.data()?['bookingStatus'] == 'paymentPending') {
        await bookingRef.update({
          'bookingStatus': 'expired',
          'holdStatus': 'expired',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _reservationService.releaseAllocations(bookingId);

        await _eventService.logEvent(
          bookingId: bookingId,
          eventType: 'expired',
          description: 'Payment hold expired. Inventory released.',
          performedBy: 'System',
          performedByRole: 'system',
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to expire hold: $e');
    }
  }

  /// Admin physical room assignment
  Future<void> assignRoomToBooking({
    required String bookingId,
    required String roomId,
    required String assignedBy,
  }) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final bDoc = await bookingRef.get();
      if (!bDoc.exists) throw DatabaseException('Booking not found');

      final booking = BookingModel.fromMap(bDoc.data()!, bookingId);

      // Verify physical room availability for stay dates
      final available = await _availabilityService.getAvailableRooms(
        propertyId: booking.propertyId,
        roomTypeId: booking.roomTypeId,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
      );

      if (!available.any((r) => r.roomId == roomId)) {
        throw DatabaseException('Selected room $roomId is not available for these dates.', code: 'ROOM_NOT_AVAILABLE');
      }

      await bookingRef.update({
        'roomId': roomId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _eventService.logEvent(
        bookingId: bookingId,
        eventType: 'roomAssigned',
        description: 'Physical Room $roomId assigned to booking.',
        performedBy: assignedBy,
        performedByRole: 'admin',
      );
    } catch (e) {
      throw DatabaseException('Failed to assign room: $e');
    }
  }
}
