import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/location.service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService storage = StorageService();
  final LocationService locationService = LocationService();
  
  bool notificationsEnabled = true;
  bool locationEnabled = false;
  String temperatureUnit = 'Celsius';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    setState(() => isLoading = true);
    try {
      final notifications = await storage.getNotificationsEnabled();
      final location = await storage.getLocationEnabled();
      final unit = await storage.getTemperatureUnit();
      
      if (mounted) {
        setState(() {
          notificationsEnabled = notifications ?? true;
          locationEnabled = location ?? false;
          temperatureUnit = unit ?? 'Celsius';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings')),
        );
      }
    }
  }

  void saveSettings() async {
    setState(() => isLoading = true);
    try {
      await storage.saveNotificationsEnabled(notificationsEnabled);
      await storage.saveLocationEnabled(locationEnabled);
      await storage.saveTemperatureUnit(temperatureUnit);
      
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings')),
        );
      }
    }
  }

  void requestLocationPermission() async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Permission'),
          content: Text('This app needs location access to provide weather for your current location.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final messenger = ScaffoldMessenger.of(this.context);
                try {
                  await locationService.getLocation();
                  if (mounted) {
                    setState(() => locationEnabled = true);
                    messenger.showSnackBar(
                      SnackBar(content: Text('Location permission granted')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Location permission denied')),
                    );
                  }
                }
              },
              child: Text('Allow'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error requesting location permission')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                // Notifications Section
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        SwitchListTile(
                          title: Text('Enable Notifications'),
                          subtitle: Text('Receive weather updates'),
                          value: notificationsEnabled,
                          onChanged: (value) async {
                            if (value) {
                              final granted = await NotificationService.requestPermission();
                              if (granted) {
                                await NotificationService.showTestNotification();
                                setState(() => notificationsEnabled = true);
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Notification permission denied')),
                                  );
                                }
                              }
                            } else {
                              await NotificationService.cancelAll();
                              setState(() => notificationsEnabled = false);
                            }
                          },
                          secondary: Icon(Icons.notifications),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Location Section
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        SwitchListTile(
                          title: Text('Use Current Location'),
                          subtitle: Text('Get weather for your location'),
                          value: locationEnabled,
                          onChanged: (value) {
                            if (value) {
                              requestLocationPermission();
                            } else {
                              setState(() => locationEnabled = false);
                            }
                          },
                          secondary: Icon(Icons.location_on),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Units Section
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Units',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        ListTile(
                          title: Text('Temperature Unit'),
                          subtitle: Text(temperatureUnit),
                          leading: Icon(Icons.thermostat),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Select Temperature Unit'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile<String>(
                                      title: Text('Celsius'),
                                      value: 'Celsius',
                                      groupValue: temperatureUnit,
                                      onChanged: (value) {
                                        setState(() => temperatureUnit = value!);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    RadioListTile<String>(
                                      title: Text('Fahrenheit'),
                                      value: 'Fahrenheit',
                                      groupValue: temperatureUnit,
                                      onChanged: (value) {
                                        setState(() => temperatureUnit = value!);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Save Button
                ElevatedButton(
                  onPressed: saveSettings,
                  child: Text('Save Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
    );
  }
}
