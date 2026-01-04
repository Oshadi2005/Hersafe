import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';

class SafetyEngine {
  List<LatLng> safePoints = [];

  void setSafePoints(List<LatLng> points) {
    safePoints = points;
  }

  double scoreRoute(RouteModel route) {
    double score = 100;

    score -= (route.distance / 1000);
    score -= (route.duration / 300);

    for (final p in route.points) {
      for (final s in safePoints) {
        final d = _haversine(p, s);
        if (d < 200) score += 5;
        if (d < 100) score += 8;
      }
    }

    if (route.profile == 'foot-walking') score += 5;
    if (route.profile == 'cycling-regular') score += 3;

    return score.clamp(0, 100);
  }

  double _haversine(LatLng a, LatLng b) {
    const R = 6371000;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);

    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);

    final h = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);

    return 2 * R * atan2(sqrt(h), sqrt(1 - h));
  }

  double _rad(double d) => d * (pi / 180);
}
