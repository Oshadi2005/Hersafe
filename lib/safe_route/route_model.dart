// lib/safe_route/route_model.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final List<LatLng> points;
  final double distance; // meters
  final double duration; // seconds

  RouteModel({
    required this.points,
    required this.distance,
    required this.duration,
  });
}
