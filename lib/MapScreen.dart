import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng
import 'package:geolocator/geolocator.dart';
import 'package:travelmate/services/firebase_service.dart';
import 'location_service.dart';
import 'weather_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  List<Polyline> _allAccommodationRoutes = [];
  String _routeDistance = "";
  bool _isLoading = true;
  String _selectedView = 'accommodations'; // Options: 'accommodations', 'trips'
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Marker _buildUserMarker() {
    if (_currentPosition == null) {
      return Marker(
        point: const LatLng(0.0, 0.0), // Dummy location if not loaded
        width: 60,
        height: 60,
        child: Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
      );
    }
    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 60,
      height: 60,
      child: Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
    );
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

    // 3. Load markers AND routes from Firestore
    await _loadMarkersAndAllRoutes();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadMarkersAndAllRoutes() async {
    List<Marker> newMarkers = [];
    List<Polyline> newPolylines = [];

    try {
      if (_selectedView == 'accommodations') {
        final accommodations = await _firebaseService.getAccommodationsList();

        // Always add the user marker
        if (_currentPosition != null) {
          newMarkers.add(_buildUserMarker());
        }

        if (accommodations.isEmpty) {
          // No accommodations: show only user marker!
          setState(() {
            _markers = newMarkers;
            _allAccommodationRoutes = [];
          });
          return;
        }

        // Add accommodation markers and straight-line polylines to all accoms
        for (var acc in accommodations) {
          if (acc.latitude != null && acc.longitude != null) {
            final LatLng accLatLng = LatLng(acc.latitude!, acc.longitude!);

            newMarkers.add(
              Marker(
                point: accLatLng,
                width: 80,
                height: 100,
                child: _buildMarker(Icons.hotel, Colors.blue, acc.name),
              ),
            );

            // Safety: Only add polyline if user location is available
            if (_currentPosition != null) {
              final LatLng userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
              newPolylines.add(
                Polyline(
                  points: [userLatLng, accLatLng],
                  color: Colors.blue,
                  strokeWidth: 4,
                ),
              );
            }
          }
        }
      } else if (_selectedView == 'trips') {
        final trips = await _firebaseService.getTripsList();

        // Always add user marker for trips as well
        if (_currentPosition != null) {
          newMarkers.add(_buildUserMarker());
        }

        // (You can add similar polylines for trips if you wish)
        for (var trip in trips) {
          if (trip.latitude != null && trip.longitude != null) {
            newMarkers.add(
              Marker(
                point: LatLng(trip.latitude!, trip.longitude!),
                width: 80,
                height: 100,
                child: _buildMarker(Icons.location_on, Colors.green, trip.destination),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Map Error: $e");
    }

    if (mounted) setState(() {
      _markers = newMarkers;
      _allAccommodationRoutes = newPolylines;
    });
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
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(0.0, 0.0),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.travelmate',
              ),
              MarkerLayer(markers: _markers),
              // --- draw all polylines at once ---
              PolylineLayer(polylines: _allAccommodationRoutes),
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
          _loadMarkersAndAllRoutes().then((_) {
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