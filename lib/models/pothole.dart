// lib/models/pothole.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Pothole {
  final String id;
  final double lat;
  final double lng;
  final int severity;        // ← devenu int
  final String? comment;     // ← nullable
  final String? imageUrl;    // ← nullable
  final DateTime reportedAt;

  Pothole({
    required this.id,
    required this.lat,
    required this.lng,
    required this.severity,
    this.comment,
    this.imageUrl,
    required this.reportedAt,
  });

  factory Pothole.fromMap(Map<String, dynamic> data, String id) {
    final loc = data['location'] as Map<String, dynamic>?;
    if (loc == null || loc['lat'] == null || loc['lng'] == null) {
      throw StateError("Le document $id ne contient pas de champ 'location'");
    }

    final rawSev = data['severity'];
    if (rawSev == null) {
      throw StateError("Le document $id ne contient pas de champ 'severity'");
    }
    final sev = (rawSev as num).toInt();

    final ts = data['timestamp'];
    if (ts == null || ts is! Timestamp) {
      throw StateError("Le document $id ne contient pas de champ 'timestamp'");
    }

    return Pothole(
      id: id,
      lat: loc['lat'].toDouble(),
      lng: loc['lng'].toDouble(),
      severity: sev,
      comment: data['comment'] as String?,
      imageUrl: data['imageUrl'] as String?,
      reportedAt: ts.toDate(),
    );
  }

  factory Pothole.fromDocument(DocumentSnapshot doc) =>
      Pothole.fromMap(doc.data() as Map<String, dynamic>, doc.id);
}
