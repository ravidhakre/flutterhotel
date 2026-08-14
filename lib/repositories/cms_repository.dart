import '../core/errors/failure.dart';
import '../models/cms_banner_model.dart';
import '../models/cms_faq_model.dart';
import '../models/cms_legal_model.dart';
import '../services/cms_service.dart';

class CMSRepository {
  final CMSService _service;

  CMSRepository({CMSService? service}) : _service = service ?? CMSService();

  Future<void> saveBanner(CMSBannerModel banner) async {
    try {
      await _service.saveBanner(banner);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> saveFAQ(CMSFAQModel faq) async {
    try {
      await _service.saveFAQ(faq);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> saveLegalDocument(CMSLegalModel legal) async {
    try {
      await _service.saveLegalDocument(legal);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }
}
