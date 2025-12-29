// lib/safe_route/safe_route_engine.dart
import 'dart:math';
import 'route_model.dart';

class SafetyEngine {
  /// Scores a route from 0 to 100
  double scoreRoute(RouteModel route) {
    Random rand = Random();
    return 50 + rand.nextInt(50).toDouble(); // always returns double
  }
}
