import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SafeRouteService {
  // 🔑 Replace with your actual ORS API key
  static const String _orsApiKey = 'YOUR_REAL_KEY_HERE';

  /// Fetch a route from ORS for a given profile
  Future<RouteModel?> fetchRouteForProfile(
    LatLng start,
    LatLng end,
    String profile,
  ) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/$profile'
      '?api_key=$_orsApiKey'
      '&start=${start.longitude},${start.latitude}'
      '&end=${end.longitude},${end.latitude}',
    );

    try {
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
        'User-Agent': 'HerSafeApp/1.0',
      });

      if (res.statusCode != 200) {
        debugPrint('ORS error [$profile]: ${res.statusCode} ${res.body}');
        return null;
      }

      final data = json.decode(res.body);
      final features = data['features'] as List?;
      if (features == null || features.isEmpty) return null;

      final feature = features[0];

      // Polyline points
      final coords = (feature['geometry']['coordinates'] as List)
          .map<LatLng>((c) => LatLng(
                (c[1] as num).toDouble(),
                (c[0] as num).toDouble(),
              ))
          .toList();

      // Summary
      final summary = feature['properties']['summary'];
      final distance = (summary['distance'] as num).toDouble();
      final duration = (summary['duration'] as num).toDouble();

      // Navigation steps
      final steps = <String>[];
      final segments = feature['properties']['segments'] as List?;
      if (segments != null && segments.isNotEmpty) {
        for (final step in segments[0]['steps']) {
          final instruction = step['instruction'];
          final dist = step['distance'];
          final dur = step['duration'];
          steps.add(
              '$instruction (${(dist / 1000).toStringAsFixed(1)} km, ${(dur / 60).round()} min)');
        }
      }

      return RouteModel(
        points: coords,
        distance: distance,
        duration: duration,
        profile: profile,
        steps: steps,
      );
    } catch (e) {
      debugPrint('ORS fetch failed [$profile]: $e');
      return null;
    }
  }

  /// Fetch routes for car, bike, walking
  Future<List<RouteModel>> fetchRoutes(LatLng start, LatLng end) async {
    const profiles = ['driving-car', 'cycling-regular', 'foot-walking'];
    final List<RouteModel> routes = [];

    for (final profile in profiles) {
      final route = await fetchRouteForProfile(start, end, profile);
      if (route != null) {
        routes.add(route);
      }
    }

    return routes;
  }
}
