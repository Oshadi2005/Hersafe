import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  final double distance; // meters
  final double duration; // seconds
  final String profile;
  List<String> steps;
  double safetyScore;

  RouteModel({
    required this.points,
    required this.distance,
    required this.duration,
    required this.profile,
    this.steps = const [],
    this.safetyScore = 0,
  });
}

