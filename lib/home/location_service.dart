import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final StreamController<String> _locationController =
      StreamController.broadcast();

  Stream<String> get locationStream => _locationController.stream;

  Future<Position> getPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getCurrentLocation() async {
    try {
      Position position = await getPosition();
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
