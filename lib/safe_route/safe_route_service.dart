// lib/safe_route/safe_route_service.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';
import 'safe_route_engine.dart';

class SafeRouteService {
  final SafetyEngine engine = SafetyEngine();

  /// Mock fetching multiple routes
  Future<List<RouteModel>> fetchRoutes(LatLng start, LatLng end) async {
    List<RouteModel> routes = [
      RouteModel(
        points: [start, LatLng(start.latitude + 0.001, start.longitude + 0.002), end],
        distance: 500,
        duration: 300,
      ),
      RouteModel(
        points: [start, LatLng(start.latitude + 0.002, start.longitude + 0.001), end],
        distance: 520,
        duration: 320,
      ),
    ];
    return routes;
  }

  /// Returns the safest route based on score
  RouteModel? getSafestRoute(List<RouteModel> routes) {
    routes.sort((a, b) => engine.scoreRoute(b).compareTo(engine.scoreRoute(a)));
    return routes.isNotEmpty ? routes.first : null;
  }

  /// Returns a color for route based on score
  Color getRouteColor(double score) {
    if (score > 80) return Colors.green;
    if (score > 50) return Colors.orange;
    return Colors.red;
  }
}
