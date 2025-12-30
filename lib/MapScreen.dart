import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  List<Polyline> _allRoutes = [];
  bool _isLoading = true;
  String _selectedView = 'accommodations';
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Marker _buildUserMarker() {
    LatLng point = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(0.0, 0.0);

    return Marker(
      point: point,
      width: 60,
      height: 60,
      child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
    );
  }

  // Helper to fetch coordinates from OSRM API
  Future<List<LatLng>> _fetchRoutePoints(LatLng from, LatLng to) async {
    final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
            '?overview=full&geometries=geojson'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
        return coords.map((c) => LatLng(c[1], c[0])).toList();
      }
    } catch (e) {
      debugPrint("Routing error: $e");
    }
    return [];
  }

  Future<void> _loadMarkersAndAllRoutes() async {
    List<Marker> newMarkers = [];
    List<Polyline> newPolylines = [];

    try {
      if (_currentPosition != null) {
        newMarkers.add(_buildUserMarker());
      }

      if (_selectedView == 'accommodations') {
        final accommodations = await _firebaseService.getAccommodationsList();
        for (var acc in accommodations) {
          if (acc.latitude != null && acc.longitude != null) {
            final LatLng dest = LatLng(acc.latitude!, acc.longitude!);
            newMarkers.add(Marker(
              point: dest,
              width: 80, height: 100,
              child: _buildMarker(Icons.hotel, Colors.blue, acc.name),
            ));

            // Fetch Blue Route for Hotels
            if (_currentPosition != null) {
              final points = await _fetchRoutePoints(
                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  dest
              );
              if (points.isNotEmpty) {
                newPolylines.add(Polyline(points: points, color: Colors.blue, strokeWidth: 4));
              }
            }
          }
        }
      } else if (_selectedView == 'trips') {
        final trips = await _firebaseService.getTripsList();
        for (var trip in trips) {
          if (trip.latitude != null && trip.longitude != null) {
            final LatLng dest = LatLng(trip.latitude!, trip.longitude!);
            newMarkers.add(Marker(
              point: dest,
              width: 80, height: 100,
              child: _buildMarker(Icons.location_on, Colors.green, trip.destination),
            ));

            // Fetch Green Route for Trips
            if (_currentPosition != null) {
              final points = await _fetchRoutePoints(
                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  dest
              );
              if (points.isNotEmpty) {
                newPolylines.add(Polyline(points: points, color: Colors.green, strokeWidth: 4));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Map Error: $e");
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _allRoutes = newPolylines;
      });
      _fitMapToAllPoints();
    }
  }

  // ... (Keep your _fitMapToAllPoints, _getBoundsCenter, _getBoundsZoom functions exactly as they are)

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    _currentPosition = await LocationService.getCurrentLocation();
    await _loadMarkersAndAllRoutes();
    if (mounted) setState(() => _isLoading = false);
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
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
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
                  : const LatLng(32.0836, 72.6711),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.travelmate.app.v1.routing.fix',
              ),
              PolylineLayer(polylines: _allRoutes), // Displays the green or blue routes
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),
          Positioned(bottom: 20, left: 20, right: 20, child: _buildViewToggle()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fitMapToAllPoints, // Calls the method you just defined
        backgroundColor: Colors.green,
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
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
        onTap: () async {
          setState(() {
            _selectedView = view;
            _isLoading = true;
          });
          await _loadMarkersAndAllRoutes();
          setState(() => _isLoading = false);
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
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
  // 1. The main function that moves the camera
  void _fitMapToAllPoints() {
    final allPoints = <LatLng>[];

    // Collect all points from the route lines
    for (final poly in _allRoutes) {
      allPoints.addAll(poly.points);
    }

    // If no routes, collect points from markers
    if (_allRoutes.isEmpty) {
      if (_currentPosition != null) {
        allPoints.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      }
      for (final marker in _markers) {
        allPoints.add(marker.point);
      }
    }

    if (allPoints.isEmpty) return;

    // Move camera based on points found
    if (allPoints.length == 1) {
      _mapController.move(allPoints.first, 13.0);
    } else {
      final center = _getBoundsCenter(allPoints);
      final zoom = _getBoundsZoom(allPoints);
      _mapController.move(center, zoom);
    }
  }

  // 2. Helper to find the center point of the view
  LatLng _getBoundsCenter(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }

  // 3. Helper to calculate how far to zoom out
  double _getBoundsZoom(List<LatLng> points) {
    final center = _getBoundsCenter(points);
    double maxDistance = 0;
    const Distance d = Distance();
    for (final point in points) {
      final dist = d(center, point);
      if (dist > maxDistance) maxDistance = dist;
    }
    // Simple zoom levels based on distance (meters)
    if (maxDistance < 300) return 14;
    if (maxDistance < 1000) return 13;
    if (maxDistance < 3000) return 12;
    if (maxDistance < 10000) return 10.5;
    return 8;
  }
}