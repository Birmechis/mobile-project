import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _locationKey = 'location_enabled';
  static const String _temperatureUnitKey = 'temperature_unit';

  // Favorites Management
  Future<void> saveFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (!favorites.contains(city)) {
      favorites.add(city);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String city) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    favorites.remove(city);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  // User Profile Management
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Settings Management
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<bool?> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey);
  }

  Future<void> saveLocationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, enabled);
  }

  Future<bool?> getLocationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationKey);
  }

  Future<void> saveTemperatureUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_temperatureUnitKey, unit);
  }

  Future<String?> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_temperatureUnitKey);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}