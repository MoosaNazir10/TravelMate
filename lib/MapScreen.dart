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
  String _selectedView = 'accommodations';
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Marker _buildUserMarker() {
    if (_currentPosition == null) {
      return Marker(
        point: const LatLng(0.0, 0.0),
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

  // Helper: Center and zoom to fit all points (compatible with flutter_map >5.x)
  void _fitMapToAllPoints() {
    final allPoints = <LatLng>[];

    // Add all route points
    for (final poly in _allAccommodationRoutes) {
      allPoints.addAll(poly.points);
    }
    // Add user location & accommodation markers if no routes
    if (_allAccommodationRoutes.isEmpty) {
      if (_currentPosition != null) {
        allPoints.add(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));
      }
      for (final marker in _markers) {
        allPoints.add(marker.point);
      }
    }

    if (allPoints.isEmpty) return;

    if (allPoints.length == 1) {
      _mapController.move(allPoints.first, 13.0);
    } else if (allPoints.length > 1) {
      final center = _getBoundsCenter(allPoints);
      final zoom = _getBoundsZoom(allPoints);
      _mapController.move(center, zoom);
    }
  }

  // Helpers for calculating map bounds manually
  LatLng _getBoundsCenter(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
  }

  double _getBoundsZoom(List<LatLng> points) {
    // Basic logic: farther apart means zoom out
    // You can fine-tune this, but start simple:
    final center = _getBoundsCenter(points);
    double maxDistance = 0;
    final Distance d = Distance();
    for (final point in points) {
      final dist = d(center, point);
      if (dist > maxDistance) maxDistance = dist;
    }
    // These formulas produce pretty good world-to-street level zooms:
    if (maxDistance < 300) return 14;       // City block
    if (maxDistance < 1000) return 13;      // City
    if (maxDistance < 3000) return 12;      // Metro
    if (maxDistance < 10000) return 10.5;   // Region
    if (maxDistance < 50000) return 9;
    if (maxDistance < 150000) return 7.5;
    return 5; // Continent!
  }

  Future<List<LatLng>> _fetchRoutePoints(LatLng from, LatLng to) async {
    try {
      final url = Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
              '${from.longitude},${from.latitude};'
              '${to.longitude},${to.latitude}'
              '?overview=full&geometries=geojson'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] == null ||
            data['routes'].isEmpty ||
            data['routes'][0]['geometry'] == null ||
            data['routes'][0]['geometry']['coordinates'] == null) {
          return [];
        }
        List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
        List<LatLng> points = coords.map((c) => LatLng(c[1], c[0])).toList();
        return points;
      }
    } catch (e) {
      debugPrint('Route API error: $e');
    }
    return [];
  }

  Future<void> _loadMarkersAndAllRoutes() async {
    List<Marker> newMarkers = [];
    List<Polyline> newPolylines = [];

    try {
      if (_selectedView == 'accommodations') {
        final accommodations = await _firebaseService.getAccommodationsList();

        if (_currentPosition != null) {
          newMarkers.add(_buildUserMarker());
        }

        if (accommodations.isEmpty) {
          setState(() {
            _markers = newMarkers;
            _allAccommodationRoutes = [];
          });
          _fitMapToAllPoints();
          return;
        }

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

            if (_currentPosition != null) {
              final LatLng userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
              List<LatLng> routePoints = await _fetchRoutePoints(userLatLng, accLatLng);
              if (routePoints.isNotEmpty) {
                newPolylines.add(
                  Polyline(
                    points: routePoints,
                    color: Colors.blue,
                    strokeWidth: 4,
                  ),
                );
              }
            }
          }
        }
      } else if (_selectedView == 'trips') {
        final trips = await _firebaseService.getTripsList();

        if (_currentPosition != null) {
          newMarkers.add(_buildUserMarker());
        }
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

    _fitMapToAllPoints();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    _currentPosition = await LocationService.getCurrentLocation();

    if (widget.showWeather && _currentPosition != null) {
      _weatherData = await WeatherService.getCurrentWeather(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
    }

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