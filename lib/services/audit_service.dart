import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase/firebase_services.dart';
import '../models/audit_log_model.dart';

class AuditService {
  final FirebaseFirestore _firestore = FirebaseServices.firestore;

  /// Log administrative modification securely
  Future<void> logAction({
    required String action,
    required String module,
    required String recordId,
    String? propertyId,
    required String performedBy,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final docRef = _firestore.collection('auditLogs').doc();
      final auditEntry = AuditLogModel(
        logId: docRef.id,
        action: action,
        module: module,
        recordId: recordId,
        propertyId: propertyId,
        performedBy: performedBy,
        oldData: oldData,
        newData: newData,
      );
      await docRef.set(auditEntry.toMap());
    } catch (_) {
      // Audit logging failure should not break primary transactions
    }
  }
}
