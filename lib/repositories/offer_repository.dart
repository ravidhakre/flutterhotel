import '../core/errors/failure.dart';
import '../models/offer_model.dart';
import '../services/offer_service.dart';

class OfferRepository {
  final OfferService _service;

  OfferRepository({OfferService? service}) : _service = service ?? OfferService();

  Future<void> saveOffer(OfferModel offer) async {
    try {
      await _service.saveOffer(offer);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<List<OfferModel>> getApplicableOffers({
    required String propertyId,
    required String roomTypeId,
    required DateTime date,
  }) async {
    try {
      return await _service.getApplicableOffers(
        propertyId: propertyId,
        roomTypeId: roomTypeId,
        date: date,
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
