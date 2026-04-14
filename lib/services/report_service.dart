// lib/services/report_service.dart

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/report_data.dart';

class ReportService {
  final _db      = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> uploadReport(ReportData report) async {
    // 1) Récupère le bucket depuis FirebaseOptions
    final bucket = Firebase.app().options.storageBucket!;
    final gsUrl   = 'gs://$bucket';

    // 2) Prépare la référence Storage
    final ref = _storage
        .refFromURL(gsUrl)
        .child('reports/${report.timestamp.millisecondsSinceEpoch}.jpg');

    // 3) Upload et récupération de l'URL
    final uploadTask = ref.putData(
      report.imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final snap = await uploadTask;
    final url  = await snap.ref.getDownloadURL();

    // 4) Écriture en Firestore avec la Map de ton modèle
    final data = report.toMap(url);
    await _db.collection('reports').add(data);
  }
}
