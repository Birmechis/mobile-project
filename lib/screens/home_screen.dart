import 'package:flutter/material.dart';
import 'weather_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../services/location.service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final ApiService apiService = ApiService();
  final LocationService locationService = LocationService();

  bool isLoading = false;
  String? errorMessage;

  void searchWeather() async {
    if (controller.text.trim().isEmpty) {
      setState(() => errorMessage = 'Please enter a city name');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Validate city exists by making a quick API call
      await apiService.fetchWeather(controller.text.trim());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeatherScreen(city: controller.text.trim()),
        ),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void getCurrentLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final position = await locationService.getLocation();
      final weather = await apiService.fetchWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeatherScreen(
            city: weather.cityName,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        ),
      );
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritesScreen()),
    );
  }

  void navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  void navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather App"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section with Stack
                  Container(
                    height: 200,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade400, Colors.blue.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Weather App',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Get weather updates for any city',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Icon(
                            Icons.cloud,
                            size: 60,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Search Section
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Weather',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: "Enter city name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city),
                              errorText: errorMessage,
                            ),
                            onSubmitted: (_) => searchWeather(),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: searchWeather,
                                  child: Text("Search"),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: getCurrentLocationWeather,
                                child: Icon(Icons.my_location),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Navigation Section
                  Text(
                    'Navigate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Navigation Buttons in Row layout
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavigationButton(
                          'Favorites',
                          Icons.favorite,
                          Colors.red,
                          navigateToFavorites,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildNavigationButton(
                          'Profile',
                          Icons.person,
                          Colors.purple,
                          navigateToProfile,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNavigationButton(
                          'Settings',
                          Icons.settings,
                          Colors.orange,
                          navigateToSettings,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildNavigationButton(
                          'About',
                          Icons.info,
                          Colors.grey,
                          () => _showAboutDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNavigationButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Weather App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A comprehensive weather application with:'),
            SizedBox(height: 8),
            Text('• Weather data from OpenWeatherMap'),
            Text('• Location-based weather'),
            Text('• User profiles and settings'),
            Text('• Favorite cities management'),
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
}