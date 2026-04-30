import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getLocation() async {
    // On mobile, check if location services are enabled
    // On web, this check is not supported, so we skip it
    if (!kIsWeb) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services disabled");
      }
    }

    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied");
    }

    // Use low accuracy on web for faster response
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: kIsWeb ? LocationAccuracy.low : LocationAccuracy.high,
    );
  }
}