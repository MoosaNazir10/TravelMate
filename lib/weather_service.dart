import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using Open-Meteo - 100% FREE, NO API KEY NEEDED!
  static const String baseUrl = 'https://api.open-meteo.com/v1';

  // Get current weather for coordinates (FREE, no API key!)
  static Future<Map<String, dynamic>?> getCurrentWeather(
      double latitude,
      double longitude,
      ) async {
    try {
      final url = '$baseUrl/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['current_weather'];
      }
      return null;
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  // Get weather forecast (FREE)
  static Future<List<Map<String, dynamic>>> getWeatherForecast(
      double latitude,
      double longitude,
      ) async {
    try {
      final url = '$baseUrl/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daily = data['daily'];

        List<Map<String, dynamic>> forecast = [];
        for (int i = 0; i < (daily['time']?.length ?? 0); i++) {
          forecast.add({
            'date':  daily['time'][i],
            'temp_max': daily['temperature_2m_max'][i],
            'temp_min': daily['temperature_2m_min'][i],
            'weathercode': daily['weathercode'][i],
          });
        }
        return forecast;
      }
      return [];
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }

  // Get temperature from weather data
  static double getTemperature(Map<String, dynamic> weather) {
    return weather['temperature']?.toDouble() ?? 0.0;
  }

  // Get weather condition from WMO code
  static String getWeatherCondition(Map<String, dynamic> weather) {
    int code = weather['weathercode'] ?? 0;

    if (code == 0) return 'Clear';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain Showers';
    if (code <= 86) return 'Snow Showers';
    if (code <= 99) return 'Thunderstorm';

    return 'Unknown';
  }

  // Get weather emoji
  static String getWeatherEmoji(Map<String, dynamic> weather) {
    int code = weather['weathercode'] ?? 0;

    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 48) return '🌫️';
    if (code <= 67) return '🌧️';
    if (code <= 77) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';

    return '🌈';
  }

  // Get wind speed
  static double getWindSpeed(Map<String, dynamic> weather) {
    return weather['windspeed']?.toDouble() ?? 0.0;
  }
}