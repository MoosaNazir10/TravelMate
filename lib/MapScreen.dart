import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng
import 'package:geolocator/geolocator.dart';
import 'package:travelmate/services/firebase_service.dart'; // Required for data fetching
import 'package:travelmate/AccommodationListScreen.dart'; // Required for Accommodation class
import 'package:travelmate/expense_models.dart'; // Required for Trip class
import 'location_service.dart';
import 'weather_service.dart';

class MapScreen extends StatefulWidget {
  final bool showWeather;

  const MapScreen({super.key, this.showWeather = true, required List<dynamic> accommodations});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final FirebaseService _firebaseService = FirebaseService();

  Position? _currentPosition;
  List<Marker> _markers = [];
  bool _isLoading = true;
  String _selectedView = 'accommodations'; // Options: 'accommodations', 'trips'
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    // 1. Get user's current location
    _currentPosition = await LocationService.getCurrentLocation();

    // 2. Fetch weather if enabled
    if (widget.showWeather && _currentPosition != null) {
      _weatherData = await WeatherService.getCurrentWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }

    // 3. Load markers from Firestore
    await _loadMarkersFromFirebase();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMarkersFromFirebase() async {
    List<Marker> newMarkers = [];

    try {
      if (_selectedView == 'accommodations') {
        // Fetch using unified model from AccommodationListScreen.dart
        final accommodations = await _firebaseService.getAccommodationsList();
        for (var acc in accommodations) {
          if (acc.latitude != null && acc.longitude != null) {
            newMarkers.add(
              Marker(
                point: LatLng(acc.latitude!, acc.longitude!),
                width: 80,
                height: 80,
                // Use 'child' instead of 'builder'
                child: _buildMarker(Icons.hotel, Colors.blue, acc.name),
              ),
            );
          }
        }
      } else if (_selectedView == 'trips') {
        // Fetch using unified model from expense_models.dart
        final trips = await _firebaseService.getTripsList();
        for (var trip in trips) {
          if (trip.latitude != null && trip.longitude != null) {
            newMarkers.add(
              Marker(
                point: LatLng(trip.latitude!, trip.longitude!),
                width: 80,
                height: 80,
                // Change 'builder' to 'child'
                child: _buildMarker(
                  Icons.location_on,
                  Colors.green,
                  trip.destination,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Map Error: Could not detect data: $e");
    }

    if (mounted) setState(() => _markers = newMarkers);
  }

  Widget _buildMarker(IconData icon, Color color, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // FIX: Changed 'center' to 'initialCenter'
              initialCenter: LatLng(
                _currentPosition?.latitude ?? 0.0,
                _currentPosition?.longitude ?? 0.0,
              ),
              // FIX: Changed 'zoom' to 'initialZoom'
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildViewToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        children: [
          _toggleButton('accommodations', Icons.hotel, 'Hotels'),
          _toggleButton('trips', Icons.map, 'Trips'),
        ],
      ),
    );
  }

  Widget _toggleButton(String view, IconData icon, String label) {
    bool isSelected = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = view;
            _isLoading = true;
          });
          _loadMarkersFromFirebase().then((_) {
            setState(() => _isLoading = false);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
