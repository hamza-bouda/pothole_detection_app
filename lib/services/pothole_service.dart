// lib/services/pothole_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pothole.dart';

class PotholeService {
  // <-- on pointe sur la collection 'reports', là où ReportService écrit
  final CollectionReference _col =
  FirebaseFirestore.instance.collection('reports');

  /// Stream de tous les signalements, triés par timestamp
  Stream<List<Pothole>> streamAll() {
    return _col
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Pothole.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    ))
        .toList());
  }
}
