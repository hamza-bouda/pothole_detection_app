// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final CameraPosition initialCamera;
  final Set<Marker> markers;
  final void Function(GoogleMapController) onMapCreated;

  const MapScreen({
    Key? key,
    required this.initialCamera,
    required this.markers,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final legendBg = theme.colorScheme.surface.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.8);
    final textStyle = theme.textTheme.bodySmall?.copyWith(fontFamily: 'Ubuntu');

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: widget.initialCamera,
          markers: widget.markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _controller = controller;
            widget.onMapCreated(controller);
          },
        ),

        // Légende des niveaux de gravité
        Positioned(
          top: 16,
          left: 16,
          child: Card(
            color: legendBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  _LegendDot(color: Colors.yellow, label: '1', textStyle: textStyle),
                  const SizedBox(width: 8),
                  _LegendDot(color: Colors.orange, label: '2', textStyle: textStyle),
                  const SizedBox(width: 8),
                  _LegendDot(color: Colors.red, label: '3', textStyle: textStyle),
                ],
              ),
            ),
          ),
        ),

        // Bouton pour recentrer la carte
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              if (_controller != null) {
                _controller!.animateCamera(CameraUpdate.newCameraPosition(widget.initialCamera));
              }
            },
            backgroundColor: accent,
            child: Icon(Icons.my_location, color: theme.colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final TextStyle? textStyle;

  const _LegendDot({Key? key, required this.color, required this.label, this.textStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: textStyle),
      ],
    );
  }
}