import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  final String city;
  final double? latitude;
  final double? longitude;

  WeatherScreen({required this.city, this.latitude, this.longitude});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final ApiService api = ApiService();
  final StorageService storage = StorageService();

  WeatherModel? weather;
  bool loading = true;
  String? errorMessage;
  String temperatureUnit = 'Celsius';

  @override
  void initState() {
    super.initState();
    _loadTemperatureUnit();
    loadWeather();
  }

  void _loadTemperatureUnit() async {
    final unit = await storage.getTemperatureUnit();
    if (mounted && unit != null) {
      setState(() => temperatureUnit = unit);
    }
  }

  String _getTemperatureDisplay(double celsius) {
    if (temperatureUnit == 'Fahrenheit') {
      final fahrenheit = (celsius * 9 / 5) + 32;
      return '${fahrenheit.toStringAsFixed(1)}°F';
    }
    return '${celsius.toStringAsFixed(1)}°C';
  }

  void loadWeather() async {
    try {
      WeatherModel result;
      
      // If coordinates are provided, use them; otherwise search by city name
      if (widget.latitude != null && widget.longitude != null) {
        result = await api.fetchWeatherByCoordinates(
          widget.latitude!, 
          widget.longitude!,
          cityName: widget.city,
        );
      } else {
        result = await api.fetchWeather(widget.city);
      }
      
      if (mounted) {
        setState(() {
          weather = result;
          loading = false;
          errorMessage = null;
        });
        _maybeShowWeatherNotification();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  void _maybeShowWeatherNotification() async {
    final enabled = await storage.getNotificationsEnabled();
    if (enabled == true && weather != null) {
      await NotificationService.showWeatherNotification(
        city: weather!.cityName,
        temperature: _getTemperatureDisplay(weather!.temperature),
        description: weather!.description,
      );
    }
  }

  void saveFavorite() async {
    try {
      await storage.saveFavorite(widget.city);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Saved to favorites"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving to favorites"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showWeatherDetails() {
    if (weather == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weather Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('City: ${weather!.cityName}'),
            SizedBox(height: 8),
            Text('Temperature: ${_getTemperatureDisplay(weather!.temperature)}'),
            SizedBox(height: 8),
            Text('Description: ${weather!.description}'),
            SizedBox(height: 8),
            Text('Humidity: ${weather!.humidity}%'),
            SizedBox(height: 8),
            Text('Wind Speed: ${weather!.windSpeed} m/s'),
            SizedBox(height: 8),
            Text('Pressure: ${weather!.pressure} hPa'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        actions: [
          IconButton(
            onPressed: loadWeather,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading weather data...'),
                ],
              ),
            )
          : errorMessage != null
              ? Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: loadWeather,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(),
                        ),
                      ],
                    ),
                  ),
                )
              : weather != null
                  ? SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Weather Card with Stack
                          Container(
                            height: 250,
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 230,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade300,
                                        Colors.blue.shade500,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    children: [
                                      Text(
                                        weather!.cityName,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        weather!.description.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 80,
                                  left: 0,
                                  right: 0,
                                  child: Column(
                                    children: [
                                      Icon(
                                        _getWeatherIcon(weather!.description),
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        _getTemperatureDisplay(weather!.temperature),
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Weather Details Grid
                          Text(
                            'Weather Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailCard(
                                  'Humidity',
                                  '${weather!.humidity.toInt()}%',
                                  Icons.water_drop,
                                  Colors.blue,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildDetailCard(
                                  'Wind Speed',
                                  '${weather!.windSpeed} m/s',
                                  Icons.air,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailCard(
                                  'Pressure',
                                  '${weather!.pressure} hPa',
                                  Icons.speed,
                                  Colors.orange,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _buildDetailCard(
                                  'Details',
                                  'View More',
                                  Icons.info,
                                  Colors.purple,
                                  onTap: showWeatherDetails,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: saveFavorite,
                                  child: Text('Save to Favorites'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Back'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Center(child: Text("No weather data available")),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear')) return Icons.wb_sunny;
    if (desc.contains('cloud')) return Icons.cloud;
    if (desc.contains('rain')) return Icons.grain;
    if (desc.contains('snow')) return Icons.ac_unit;
    if (desc.contains('thunder')) return Icons.flash_on;
    if (desc.contains('mist') || desc.contains('fog')) return Icons.foggy;
    return Icons.cloud;
  }
}