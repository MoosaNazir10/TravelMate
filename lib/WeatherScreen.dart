import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherFromOpenMeteo();
  }

  Future<void> _fetchWeatherFromOpenMeteo() async {
    try {
      setState(() => _isLoading = true);

      // 1. Get Device Location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low // Low accuracy is faster and enough for weather
      );

      // 2. Fetch from Open-Meteo (No Key Needed)
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,visibility&forecast_days=1';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];

        setState(() {
          _weatherData = {
            'cityName': 'Current Location', // Open-Meteo doesn't provide names, only coords
            'temperature': current['temperature_2m'].round(),
            'feelsLike': current['apparent_temperature'].round(),
            'condition': _getWeatherDescription(current['weather_code']),
            'humidity': current['relative_humidity_2m'],
            'windSpeed': current['wind_speed_10m'],
            'visibility': (current['visibility'] / 1000).round(),
            'icon': _getWeatherIcon(current['weather_code']),
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load weather');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Make sure location is on and try again.";
        _isLoading = false;
      });
    }
  }

  // WMO Weather interpretation codes
  String _getWeatherDescription(int code) {
    if (code == 0) return "Clear sky";
    if (code <= 3) return "Partly cloudy";
    if (code <= 48) return "Foggy";
    if (code <= 67) return "Rainy";
    if (code <= 77) return "Snowy";
    return "Stormy";
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code <= 67) return Icons.umbrella;
    return Icons.thunderstorm;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.green)));
    if (_errorMessage.isNotEmpty) return Scaffold(body: Center(child: Text(_errorMessage)));

    final weather = _weatherData!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Real-time Weather", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: _fetchWeatherFromOpenMeteo,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(weather['icon'], size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text("${weather['temperature']}°C",
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200)),
            Text(weather['condition'],
                style: const TextStyle(fontSize: 24, color: Colors.black54)),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetric(Icons.water_drop, 'Humidity', '${weather['humidity']}%'),
                _buildMetric(Icons.air, 'Wind', '${weather['windSpeed']} km/h'),
                _buildMetric(Icons.visibility, 'Visibility', '${weather['visibility']} km'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.green),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}