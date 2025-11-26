import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final StreamController<String> _locationController = StreamController.broadcast();

  Stream<String> get locationStream => _locationController.stream;

  Future<String> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          _locationController.add('Location permission denied');
          return 'Location permission denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String loc = '${position.latitude}, ${position.longitude}';
      _locationController.add(loc);
      return loc;
    } catch (e) {
      _locationController.add('Location not available');
      return 'Location not available';
    }
  }

  void startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      String loc = '${position.latitude}, ${position.longitude}';
      _locationController.add(loc);
    }, onError: (error) {
      _locationController.add('Error fetching location: $error');
    });
  }

  void dispose() {
    _locationController.close();
  }
}
