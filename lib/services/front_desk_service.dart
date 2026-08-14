import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/booking_model.dart';
import 'audit_service.dart';
import 'availability_service.dart';
import 'booking_event_service.dart';
import 'invoice_service.dart';
import 'reservation_service.dart';
import 'room_service.dart';

class FrontDeskService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final RoomService _roomService = RoomService();
  final AvailabilityService _availabilityService = AvailabilityService();
  final BookingEventService _eventService = BookingEventService();
  final AuditService _auditService = AuditService();
  final ReservationService _reservationService = ReservationService();
  final InvoiceService _invoiceService = InvoiceService();

  /// Perform Check-In Operation
  Future<void> checkInGuest({
    required String bookingId,
    required String performedBy,
  }) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final doc = await bookingRef.get();
      if (!doc.exists) throw DatabaseException('Booking not found');

      final booking = BookingModel.fromMap(doc.data()!, bookingId);

      // Validation
      if (booking.bookingStatus == 'cancelled' || booking.bookingStatus == 'expired') {
        throw DatabaseException('Cannot check in a cancelled or expired booking.', code: 'INVALID_STATUS');
      }

      if (booking.roomId == null || booking.roomId!.isEmpty) {
        throw DatabaseException('Physical room must be assigned before check-in.', code: 'NO_ROOM_ASSIGNED');
      }

      // Update Booking Status
      await bookingRef.update({
        'bookingStatus': 'checkedIn',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Physical Room Status to Occupied
      await _roomService.updateRoomStatus(
        roomId: booking.roomId!,
        newStatus: 'occupied',
        reason: 'Guest checked in for Booking #$bookingId',
        changedBy: performedBy,
      );

      // Log Event & Audit
      await _eventService.logEvent(
        bookingId: bookingId,
        eventType: 'checkIn',
        description: 'Guest checked in successfully to Room ${booking.roomId}.',
        performedBy: performedBy,
        performedByRole: 'admin',
      );

      await _auditService.logAction(
        action: 'GUEST_CHECKED_IN',
        module: 'FRONT_DESK',
        recordId: bookingId,
        propertyId: booking.propertyId,
        performedBy: performedBy,
      );
    } catch (e) {
      throw DatabaseException('Check-in failed: $e');
    }
  }

  /// Perform Check-Out Operation
  Future<void> checkOutGuest({
    required String bookingId,
    required String performedBy,
  }) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final doc = await bookingRef.get();
      if (!doc.exists) throw DatabaseException('Booking not found');

      final booking = BookingModel.fromMap(doc.data()!, bookingId);

      if (booking.bookingStatus != 'checkedIn') {
        throw DatabaseException('Only currently checked-in guests can check out.', code: 'NOT_CHECKED_IN');
      }

      // Generate Final Invoice
      await _invoiceService.generateInvoice(booking, issuedBy: performedBy);

      // Update Booking Status
      await bookingRef.update({
        'bookingStatus': 'checkedOut',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Physical Room Status to Cleaning
      if (booking.roomId != null && booking.roomId!.isNotEmpty) {
        await _roomService.updateRoomStatus(
          roomId: booking.roomId!,
          newStatus: 'cleaning',
          reason: 'Guest checked out for Booking #$bookingId. Housekeeping required.',
          changedBy: performedBy,
        );
      }

      // Log Event & Audit
      await _eventService.logEvent(
        bookingId: bookingId,
        eventType: 'checkOut',
        description: 'Guest checked out successfully.',
        performedBy: performedBy,
        performedByRole: 'admin',
      );

      await _auditService.logAction(
        action: 'GUEST_CHECKED_OUT',
        module: 'FRONT_DESK',
        recordId: bookingId,
        propertyId: booking.propertyId,
        performedBy: performedBy,
      );
    } catch (e) {
      throw DatabaseException('Check-out failed: $e');
    }
  }

  /// Move Guest from Room A to Room B
  Future<void> moveRoom({
    required String bookingId,
    required String newRoomId,
    required String reason,
    required String performedBy,
  }) async {
    try {
      final bookingRef = _firestore.collection(FirebaseConstants.bookingsCollection).doc(bookingId);
      final doc = await bookingRef.get();
      if (!doc.exists) throw DatabaseException('Booking not found');

      final booking = BookingModel.fromMap(doc.data()!, bookingId);
      final oldRoomId = booking.roomId;

      // Update Booking Room ID
      await bookingRef.update({
        'roomId': newRoomId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Old Room -> Cleaning
      if (oldRoomId != null && oldRoomId.isNotEmpty) {
        await _roomService.updateRoomStatus(
          roomId: oldRoomId,
          newStatus: 'cleaning',
          reason: 'Room move to $newRoomId. Reason: $reason',
          changedBy: performedBy,
        );
      }

      // New Room -> Occupied (if already checked in) or Reserved
      final newRoomStatus = booking.bookingStatus == 'checkedIn' ? 'occupied' : 'reserved';
      await _roomService.updateRoomStatus(
        roomId: newRoomId,
        newStatus: newRoomStatus,
        reason: 'Room move from $oldRoomId. Reason: $reason',
        changedBy: performedBy,
      );

      await _eventService.logEvent(
        bookingId: bookingId,
        eventType: 'roomMoved',
        description: 'Guest moved from Room $oldRoomId to Room $newRoomId. Reason: $reason',
        performedBy: performedBy,
        performedByRole: 'admin',
      );
    } catch (e) {
      throw DatabaseException('Room move failed: $e');
    }
  }
}
