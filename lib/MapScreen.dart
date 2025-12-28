import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Required for LatLng
import 'package:geolocator/geolocator.dart';
import 'package:travelmate/services/firebase_service.dart';
import 'package:travelmate/AccommodationListScreen.dart';
import 'package:travelmate/expense_models.dart';
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
  List<LatLng> _routePoints = [];
  String _routeDistance = "";
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
        final accommodations = await _firebaseService.getAccommodationsList();
        for (var acc in accommodations) {
          if (acc.latitude != null && acc.longitude != null) {
            newMarkers.add(
              Marker(
                point: LatLng(acc.latitude!, acc.longitude!),
                width: 80,
                height: 100, // Increased height to prevent clipping
                child: GestureDetector(
                  onTap: () async {
                    await _calculateRoute(LatLng(acc.latitude!, acc.longitude!));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Distance: $_routeDistance")),
                      );
                    }
                  },
                  child: _buildMarker(Icons.hotel, Colors.blue, acc.name),
                ),
              ),
            );
          }
        }
      } else if (_selectedView == 'trips') {
        final trips = await _firebaseService.getTripsList();
        for (var trip in trips) {
          if (trip.latitude != null && trip.longitude != null) {
            newMarkers.add(
              Marker(
                point: LatLng(trip.latitude!, trip.longitude!),
                width: 80,
                height: 100,
                child: GestureDetector(
                  onTap: () async {
                    await _calculateRoute(LatLng(trip.latitude!, trip.longitude!));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Distance: $_routeDistance")),
                      );
                    }
                  },
                  child: _buildMarker(Icons.location_on, Colors.green, trip.destination),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Map Error: $e");
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
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(0.0, 0.0), // Use a dummy center instead of bounds
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.travelmate',
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

  Future<void> _calculateRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${_currentPosition!.longitude},${_currentPosition!.latitude};'
            '${destination.longitude},${destination.latitude}'
            '?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Defensive: Check that 'routes' is not empty and has valid geometry
        if (data['routes'] == null ||
            data['routes'].isEmpty ||
            data['routes'][0]['geometry'] == null ||
            data['routes'][0]['geometry']['coordinates'] == null) {
          setState(() {
            _routePoints = [];
            _routeDistance = "";
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No route could be found!'))
          );
          return;
        }

        final route = data['routes'][0];

        // Convert distance from meters to km
        double distance = route['distance'] / 1000.0;

        // Parse the path coordinates
        List<dynamic> coords = route['geometry']['coordinates'];
        List<LatLng> points = coords.map((c) => LatLng(c[1], c[0])).toList();

        setState(() {
          _routePoints = points;
          _routeDistance = "${distance.toStringAsFixed(1)} km";
        });

        // Only fit the route if there are route points
        if (_routePoints.isNotEmpty) {
          _fitRoute();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No route could be found!'))
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Route service unavailable. Try again later.'))
        );
      }
    } catch (e) {
      debugPrint("Routing error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error. Please check your network.'))
      );
    }
  }

  void _fitRoute() {
    // Safety check: if there is no route, don't try to zoom
    if (_routePoints.isEmpty) return;


  }
}