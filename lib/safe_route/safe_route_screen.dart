import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'safe_route_service.dart';
import 'route_model.dart';

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  _SafeRouteScreenState createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  GoogleMapController? _controller;
  final SafeRouteService safeRouteService = SafeRouteService();
  LatLng start = LatLng(6.9271, 79.8612); // Colombo
  LatLng end = LatLng(6.9275, 79.8670);

  List<Polyline> polylines = [];

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    List<RouteModel> routes = await safeRouteService.fetchRoutes(start, end);
    RouteModel? safest = safeRouteService.getSafestRoute(routes);

    if (safest != null) {
      setState(() {
        polylines = [
          Polyline(
            polylineId: const PolylineId('safest'),
            points: safest.points,
            color: safeRouteService.getRouteColor(safeRouteService.engine.scoreRoute(safest)),
            width: 5,
          )
        ];
      });

      LatLngBounds bounds = _boundsFromLatLngList(safest.points);
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list[0].latitude;
    double x1 = list[0].latitude;
    double y0 = list[0].longitude;
    double y1 = list[0].longitude;

    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Route')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: start, zoom: 14),
        polylines: Set<Polyline>.of(polylines),
        onMapCreated: (controller) => _controller = controller,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
