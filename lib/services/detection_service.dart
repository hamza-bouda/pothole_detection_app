/// detection_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DetectionService {
  static const String _apiUrl = 'http://192.168.1.51:8000/detect';

  /// Appelle l'API pour analyser l'image et renvoie true si un nid-de-poule est détecté
  Future<bool> detectPothole(File image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['potholeDetected'] == true;
    } else {
      throw Exception('Échec de l\'analyse (code: \${response.statusCode})');
    }
  }

  /// Upload l'image et les données du signalement dans Firebase
  Future<void> uploadSignalReport({
    required File image,
    required String userId,
    required String severity,
    required String comment,
  }) async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    String fileName = '\${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = FirebaseStorage.instance.ref().child('reports/\$fileName');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('reports').add({
      'userId': userId,
      'severity': severity,
      'comment': comment,
      'location': {'lat': position.latitude, 'lng': position.longitude},
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
