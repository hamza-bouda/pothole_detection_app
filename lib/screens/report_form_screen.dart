// lib/screens/report_form_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/report_data.dart';

class ReportFormScreen extends StatefulWidget {
  final String userId;
  final Uint8List imageBytes;
  final Position position;

  const ReportFormScreen({
    Key? key,
    required this.userId,
    required this.imageBytes,
    required this.position,
  }) : super(key: key);

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _severity = 1;
  String? _comment;
  late DateTime _ts;

  @override
  void initState() {
    super.initState();
    _ts = DateTime.now();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final report = ReportData(
      userId: widget.userId,
      imageBytes: widget.imageBytes,
      position: widget.position,
      severity: _severity,
      comment: _comment,
      timestamp: _ts,
    );
    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Formulaire de signalement',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview de l'image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                widget.imageBytes,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Carte des coordonnées
            Card(
              color: surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.place, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.position.latitude.toStringAsFixed(6)}, ${widget.position.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          color: onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Formulaire
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sélecteur de gravité
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Sévérité',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                    value: _severity,
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text('Léger'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text('Modéré'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Text('Grave'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _severity = v!),
                  ),
                  const SizedBox(height: 16),

                  // Commentaire
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Commentaire (optionnel)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                    maxLines: 4,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: onSurface,
                    ),
                    onSaved: (v) => _comment = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Envoyer',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
