// lib/screens/detection_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/detection_service.dart';
import '../services/report_service.dart';
import '../models/report_data.dart';
import 'report_form_screen.dart';

class DetectionScreen extends StatefulWidget {
  final String userId;
  const DetectionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _DetectionScreenState createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool? _potholeDetected;
  Position? _currentPosition;

  final _detectionService = DetectionService();
  final _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _locateMe();
  }

  Future<void> _locateMe() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      _selectedImage = File(picked.path);
      _potholeDetected = null;
    });
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() => _isAnalyzing = true);
    try {
      final detected = await _detectionService.detectPothole(_selectedImage!);
      setState(() => _potholeDetected = detected);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l’analyse'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _openReportForm() async {
    if (_selectedImage == null || _currentPosition == null) return;
    final bytes = await _selectedImage!.readAsBytes();
    final result = await Navigator.push<ReportData>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportFormScreen(
          userId: widget.userId,
          imageBytes: bytes,
          position: _currentPosition!,
        ),
      ),
    );
    if (result != null) {
      _showConfirmation();
      await _reportService.uploadReport(result);
      setState(() {
        _selectedImage = null;
        _potholeDetected = null;
      });
    }
  }

  void _showConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Merci'),
        content: Text('Votre signalement a bien été transmis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Détection', style: TextStyle(fontFamily: 'Ubuntu')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              )
                  : Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(Icons.camera_alt, size: 80, color: theme.colorScheme.primary.withOpacity(0.7)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Capturer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: _isAnalyzing
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.search),
              label: Text(_isAnalyzing ? 'Analyse en cours...' : 'Analyser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: (_selectedImage != null && !_isAnalyzing) ? _analyzeImage : null,
            ),
            const SizedBox(height: 16),
            if (_potholeDetected == false)
              Text(
                'Aucun nid-de-poule détecté.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            if (_potholeDetected == true)
              ElevatedButton.icon(
                icon: Icon(Icons.report),
                label: Text('Signaler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _openReportForm,
              ),
          ],
        ),
      ),
    );
  }
}