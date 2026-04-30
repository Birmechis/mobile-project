import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'weather_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final StorageService storage = StorageService();
  List<String> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() async {
    setState(() => isLoading = true);
    try {
      final data = await storage.getFavorites();
      setState(() {
        favorites = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites')),
      );
    }
  }

  void removeFavorite(String city) async {
    try {
      await storage.removeFavorite(city);
      setState(() => favorites.remove(city));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$city removed from favorites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing favorite')),
      );
    }
  }

  void navigateToWeather(String city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WeatherScreen(city: city),
      ),
    ).then((_) => loadFavorites()); // Refresh when coming back
  }

  void showDeleteConfirmation(String city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Favorite'),
        content: Text('Are you sure you want to remove $city from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              removeFavorite(city);
            },
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        actions: [
          IconButton(
            onPressed: loadFavorites,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add cities to your favorites to see them here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Search Cities'),
                        style: ElevatedButton.styleFrom(),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Summary Card
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Favorites',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${favorites.length} ${favorites.length == 1 ? 'city' : 'cities'} saved',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.favorite,
                            size: 32,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    // Favorites List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favorites.length,
                        itemBuilder: (_, i) {
                          final city = favorites[i];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade100,
                                child: Icon(
                                  Icons.location_city,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(
                                city,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text('Tap to view weather'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => navigateToWeather(city),
                                    icon: Icon(
                                      Icons.cloud,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => showDeleteConfirmation(city),
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => navigateToWeather(city),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}