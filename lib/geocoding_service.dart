import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  // Using Nominatim - OpenStreetMap's FREE geocoding service
  static const String baseUrl = 'https://nominatim.openstreetmap.org';

  // Convert address to coordinates (FREE - no API key!)
  static Future<Map<String, double>?> getCoordinatesFromAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = '$baseUrl/search?q=$encodedAddress&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TravelMate App', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'latitude': double.parse(data[0]['lat']),
            'longitude': double.parse(data[0]['lon']),
          };
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }

  // Convert coordinates to address (FREE)
  static Future<String?> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      final url = '$baseUrl/reverse?lat=$latitude&lon=$longitude&format=json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TravelMate App',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
      return null;
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  // Search places (FREE)
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$baseUrl/search?q=$encodedQuery&format=json&limit=5';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'TravelMate App',
        },
      );

      if (response. statusCode == 200) {
        final List data = json.decode(response. body);
        return data.map((item) => {
          'name': item['display_name'],
          'latitude': double.parse(item['lat']),
          'longitude': double.parse(item['lon']),
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}