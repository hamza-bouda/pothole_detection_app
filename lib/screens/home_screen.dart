// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/pothole_service.dart';
import '../models/pothole.dart';
import 'detection_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // 0=Detect,1=Map,2=History,3=Settings
  final PotholeService _potholeService = PotholeService();
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _locateMe();
    _potholeService.streamAll().listen(_updateMarkers);
  }

  Future<void> _locateMe() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void _updateMarkers(List<Pothole> list) {
    setState(() {
      _markers = list.map((p) {
        double hue;
        switch (p.severity) {
          case 3:
            hue = BitmapDescriptor.hueRed;
            break;
          case 2:
            hue = BitmapDescriptor.hueOrange;
            break;
          default:
            hue = BitmapDescriptor.hueYellow;
        }
        return Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.lat, p.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: 'Nid-de-poule',
            snippet: p.comment != null && p.comment!.isNotEmpty
                ? 'Gravité : ${p.severity}\nCommentaire : ${p.comment}'
                : 'Gravité : ${p.severity}',
            onTap: () => _showDetails(p),
          ),
        );
      }).toSet();
    });
  }

  void _showDetails(Pothole p) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: theme.colorScheme.surface,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails du signalement',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            if (p.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(p.imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text('Gravité : ${p.severity}', style: theme.textTheme.bodyMedium),
            if (p.comment != null && p.comment!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Commentaire : ${p.comment}', style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            Text('Signalé le : ${p.reportedAt.toLocal()}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.background;
    final primary = theme.colorScheme.primary;
    final unselected = theme.bottomNavigationBarTheme.unselectedItemColor;

    final user = FirebaseAuth.instance.currentUser!;
    final userId = user.uid;

    final initialCamera = _currentPosition != null
        ? CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 15)
        : CameraPosition(target: LatLng(0, 0), zoom: 1);

    final mapTab = _currentPosition == null
        ? Center(child: CircularProgressIndicator(color: primary))
        : MapScreen(initialCamera: initialCamera, markers: _markers, onMapCreated: (c) => _mapController = c);

    final tabs = [DetectionScreen(userId: userId), mapTab, HistoryScreen(), SettingsScreen()];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('SmartRoute', style: theme.textTheme.titleLarge),
        centerTitle: true,
        elevation: theme.appBarTheme.elevation,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
        actions: [
          IconButton(icon: Icon(Icons.logout), color: primary, onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      drawer: AppDrawer(),
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: primary,
        unselectedItemColor: unselected,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.gps_fixed), label: 'Détecter'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Paramètres'),
        ],
      ),
    );
  }
}
