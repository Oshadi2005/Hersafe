import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../home/location_service.dart';
import 'safe_route_service.dart';
import 'route_model.dart';

class SafeRouteScreen extends StatefulWidget {
  @override
  _SafeRouteScreenState createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  GoogleMapController? _controller;
  final SafeRouteService safeRouteService = SafeRouteService();

  LatLng? currentLocation;
  LatLng? destination;

  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  void _loadCurrentLocation() async {
    final pos = await LocationService().getCurrentLocation();
    setState(() {
      currentLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  void _findSafeRoute() async {
    if (currentLocation == null || destination == null) return;

    RouteModel safest = await safeRouteService.getSafestRoute(
      currentLocation!.latitude,
      currentLocation!.longitude,
      destination!.latitude,
      destination!.longitude,
    );

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId("safe_route"),
          points: safest.points,
          color: Colors.green,
          width: 6,
        )
      };
    });

    _controller?.animateCamera(CameraUpdate.newLatLng(safest.points.first));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Safe Route")),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: _polylines,
                  onMapCreated: (ctrl) => _controller = ctrl,
                  onTap: (latLng) {
                    setState(() => destination = latLng);
                  },
                ),

                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _findSafeRoute,
                    child: Text("Find Safe Route"),
                  ),
                ),
              ],
            ),
    );
  }
}
