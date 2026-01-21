import 'package:geolocator/geolocator.dart';

class LocationShareService {
  static Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services disabled');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static String buildShareMessage(double lat, double lng) {
    return '''
I’m sharing my current location.
Please track me here 👇
https://www.google.com/maps?q=$lat,$lng
''';
  }
}
