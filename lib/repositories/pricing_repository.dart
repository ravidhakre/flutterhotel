import '../core/errors/failure.dart';
import '../models/property_model.dart';
import '../models/room_type_model.dart';
import '../services/pricing_service.dart';

class PricingRepository {
  final PricingService _service;

  PricingRepository({PricingService? service}) : _service = service ?? PricingService();

  PricingResult calculatePrice({
    required PropertyModel property,
    required RoomTypeModel roomType,
    required DateTime checkIn,
    required DateTime checkOut,
    required int rooms,
    required int adults,
    required int children,
    double discount = 0.0,
  }) {
    try {
      return _service.calculatePrice(
        property: property,
        roomType: roomType,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
        adults: adults,
        children: children,
        discount: discount,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
