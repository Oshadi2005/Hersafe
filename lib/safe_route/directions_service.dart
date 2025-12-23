import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'route_model.dart';

class DirectionsService {
  final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY";

  Future<List<RouteModel>> getRoutes(
      double startLat,
      double startLng,
      double endLat,
      double endLng) async {
    
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$startLat,$startLng&destination=$endLat,$endLng"
        "&alternatives=true&mode=walking&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    List<RouteModel> routes = [];

    for (var route in data["routes"]) {
      final polyline = route["overview_polyline"]["points"];
      final decoded = PolylinePoints()
          .decodePolyline(polyline)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      routes.add(RouteModel(points: decoded));
    }

    return routes;
  }
}

