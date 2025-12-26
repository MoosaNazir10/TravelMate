import 'package:geolocator/geolocator.dart';
import 'geocoding_service.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator. checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission. denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  static Future<Position? > getCurrentLocation() async {
    try {
      bool hasPermission = await checkLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Convert address to coordinates using FREE Nominatim
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    return await GeocodingService.getCoordinatesFromAddress(address);
  }

  // Convert coordinates to address using FREE Nominatim
  static Future<String?> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    return await GeocodingService.getAddressFromCoordinates(latitude, longitude);
  }

  // Calculate distance between two points (in km)
  static double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // km
  }
}