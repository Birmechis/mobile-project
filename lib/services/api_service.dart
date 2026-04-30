import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'dart:io';

class ApiService {
  // Open-Meteo API - Free, no API key required
  static const String geocodingUrl = "https://geocoding-api.open-meteo.com/v1/search";
  static const String weatherUrl = "https://api.open-meteo.com/v1/forecast";

  Future<WeatherModel> fetchWeather(String city) async {
    try {
      // First, get coordinates from city name using geocoding API
      final geocodingResponse = await http.get(
        Uri.parse("$geocodingUrl?name=$city&count=1"),
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (geocodingResponse.statusCode != 200) {
        throw Exception('Failed to find city location');
      }

      final geocodingData = jsonDecode(geocodingResponse.body);

      if (geocodingData['results'] == null || geocodingData['results'].isEmpty) {
        throw Exception('City not found');
      }

      final location = geocodingData['results'][0];
      final double lat = location['latitude'];
      final double lon = location['longitude'];
      final String cityName = location['name'];
      final String country = location['country'] ?? '';

      // Now fetch weather using coordinates
      return await fetchWeatherByCoordinates(lat, lon, cityName: '$cityName, $country');
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<String> getCityNameFromCoordinates(double lat, double lon) async {
    try {
      // Use Open-Meteo geocoding API for reverse geocoding
      final url =
          "https://geocoding-api.open-meteo.com/v1/reverse?latitude=$lat&longitude=$lon";
      
      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['name'] ?? 'Unknown Location';
        }
      }
      
      // Fallback: use coordinates as identifier
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    } catch (e) {
      return '${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}';
    }
  }

  Future<WeatherModel> fetchWeatherByCoordinates(double lat, double lon, {String? cityName}) async {
    try {
      final url =
          "$weatherUrl?latitude=$lat&longitude=$lon&current_weather=true&hourly=relativehumidity_2m,pressure_msl";

      final response = await http.get(Uri.parse(url)).timeout(
        Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Convert Open-Meteo data to WeatherModel format
        final currentWeather = data['current_weather'];
        final hourly = data['hourly'];
        
        // Get city name if not provided
        final actualCityName = cityName ?? await getCityNameFromCoordinates(lat, lon);

        return WeatherModel(
          cityName: actualCityName,
          temperature: currentWeather['temperature'].toDouble(),
          description: _getWeatherDescription(currentWeather['weathercode']),
          icon: _getWeatherIcon(currentWeather['weathercode']),
          humidity: hourly['relativehumidity_2m'][0].toDouble(),
          windSpeed: currentWeather['windspeed'].toDouble(),
          pressure: hourly['pressure_msl'][0].toInt(),
        );
      } else {
        throw Exception('Failed to load weather by coordinates: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error fetching weather by coordinates: $e');
    }
  }

  String _getWeatherDescription(int weatherCode) {
    // WMO Weather interpretation codes (WW)
    final Map<int, String> weatherCodes = {
      0: 'clear sky',
      1: 'mainly clear',
      2: 'partly cloudy',
      3: 'overcast',
      45: 'fog',
      48: 'depositing rime fog',
      51: 'light drizzle',
      53: 'moderate drizzle',
      55: 'dense drizzle',
      56: 'light freezing drizzle',
      57: 'dense freezing drizzle',
      61: 'slight rain',
      63: 'moderate rain',
      65: 'heavy rain',
      66: 'light freezing rain',
      67: 'heavy freezing rain',
      71: 'slight snow fall',
      73: 'moderate snow fall',
      75: 'heavy snow fall',
      77: 'snow grains',
      80: 'slight rain showers',
      81: 'moderate rain showers',
      82: 'violent rain showers',
      85: 'slight snow showers',
      86: 'heavy snow showers',
      95: 'thunderstorm',
      96: 'thunderstorm with slight hail',
      99: 'thunderstorm with heavy hail',
    };
    return weatherCodes[weatherCode] ?? 'unknown';
  }

  String _getWeatherIcon(int weatherCode) {
    // Map weather codes to icon names
    if (weatherCode == 0) return '01d';
    if (weatherCode <= 3) return '02d';
    if (weatherCode <= 48) return '50d';
    if (weatherCode <= 57) return '09d';
    if (weatherCode <= 67) return '10d';
    if (weatherCode <= 77) return '13d';
    if (weatherCode <= 86) return '09d';
    return '11d';
  }
}