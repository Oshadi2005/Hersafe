import 'directions_service.dart';
import 'safety_scoring_service.dart';
import 'route_model.dart';

class SafeRouteService {
  final DirectionsService directionsService = DirectionsService();
  final SafetyScoringService scoringService = SafetyScoringService();

  Future<RouteModel> getSafestRoute(
      double startLat, double startLng, double endLat, double endLng) async {
    final routes = await directionsService.getRoutes(
      startLat,
      startLng,
      endLat,
      endLng,
    );

    if (routes.isEmpty) {
      throw Exception(
          "No safe routes found. Please check your internet connection and API Key.");
    }

    for (var route in routes) {
      route.safetyScore = scoringService.calculateScore(route.points);
    }

    routes.sort((a, b) => b.safetyScore.compareTo(a.safetyScore));

    return routes.first;
  }
}
