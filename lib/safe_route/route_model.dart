import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  int safetyScore;

  RouteModel({
    required this.points,
    this.safetyScore = 0,
  });
}
