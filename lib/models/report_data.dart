// lib/models/report_data.dart

import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';

class ReportData {
  final String userId;
  final Uint8List imageBytes;
  final Position position;
  final int severity;
  final String? comment;
  final DateTime timestamp;

  ReportData({
    required this.userId,
    required this.imageBytes,
    required this.position,
    required this.severity,
    this.comment,
    required this.timestamp,
  });

  /// Génère la Map à envoyer en Firestore, en recevant l'URL de l'image uploadée
  Map<String, dynamic> toMap(String imageUrl) {
    return {
      'userId':    userId,
      'severity':  severity,
      'comment':   comment,
      'location': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'imageUrl':  imageUrl,
      'timestamp':   timestamp.toUtc(),
    };
  }
}

