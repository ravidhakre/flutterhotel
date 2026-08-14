import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exceptions.dart';
import '../firebase/firebase_services.dart';
import '../models/cms_banner_model.dart';
import '../models/cms_faq_model.dart';
import '../models/cms_legal_model.dart';
import 'audit_service.dart';

class CMSService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;
  final AuditService _auditService = AuditService();

  /// Save or update Homepage Banner
  Future<void> saveBanner(CMSBannerModel banner) async {
    try {
      final docRef = banner.bannerId.isNotEmpty
          ? _firestore.collection('cmsBanners').doc(banner.bannerId)
          : _firestore.collection('cmsBanners').doc();

      await docRef.set(banner.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save banner: $e');
    }
  }

  /// Save or update FAQ
  Future<void> saveFAQ(CMSFAQModel faq) async {
    try {
      final docRef = faq.faqId.isNotEmpty
          ? _firestore.collection('cmsFAQs').doc(faq.faqId)
          : _firestore.collection('cmsFAQs').doc();

      await docRef.set(faq.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw DatabaseException('Failed to save FAQ: $e');
    }
  }

  /// Update Legal Document Content with Versioning
  Future<void> saveLegalDocument(CMSLegalModel legal) async {
    try {
      final docRef = _firestore.collection('cmsLegal').doc(legal.legalId);
      final snapshot = await docRef.get();
      final currentVersion = snapshot.exists ? ((snapshot.data()?['version'] as num?)?.toInt() ?? 1) : 0;

      final updatedLegal = CMSLegalModel(
        legalId: legal.legalId,
        title: legal.title,
        version: currentVersion + 1,
        content: legal.content,
        updatedBy: legal.updatedBy,
      );

      await docRef.set(updatedLegal.toMap());

      await _auditService.logAction(
        action: 'LEGAL_DOCUMENT_UPDATED',
        module: 'CMS',
        recordId: legal.legalId,
        performedBy: legal.updatedBy,
        newData: updatedLegal.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to save legal document: $e');
    }
  }
}
