import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../home/location_service.dart';
import 'safe_route_service.dart';

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  SafeRouteScreenState createState() => SafeRouteScreenState();
}

class SafeRouteScreenState extends State<SafeRouteScreen> {
  GoogleMapController? _controller;
  final SafeRouteService safeRouteService = SafeRouteService();

  LatLng? currentLocation;
  LatLng? destination;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  void _loadCurrentLocation() async {
    try {
      final pos = await LocationService().getPosition();
      if (!mounted) return;
      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
      });
    } catch (e) {
      debugPrint("Error getting location: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not get location: $e")),
      );
    }
  }

  void _findSafeRoute() async {
    if (currentLocation == null || destination == null) return;

    try {
      final safest = await safeRouteService.getSafestRoute(
        currentLocation!.latitude,
        currentLocation!.longitude,
        destination!.latitude,
        destination!.longitude,
      );

      if (!mounted) return;
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId("safe_route"),
            points: safest.points,
            color: Colors.green,
            width: 6,
          )
        };
        _markers.add(
          Marker(
            markerId: const MarkerId("destination"),
            position: destination!,
            infoWindow: const InfoWindow(title: "Destination"),
          ),
        );
      });

      _controller?.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: safest.points.first,
          northeast: safest.points.last,
        ),
        50,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Safety Score: ${safest.safetyScore}"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Safe Route")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
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
                  markers: _markers,
                  onMapCreated: (ctrl) => _controller = ctrl,
                  onTap: (latLng) {
                    debugPrint("Destination selected: $latLng");
                    setState(() {
                      destination = latLng;
                      _markers = {
                        Marker(
                          markerId: const MarkerId("destination"),
                          position: latLng,
                          infoWindow: const InfoWindow(title: "Destination"),
                        )
                      };
                    });
                  },
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: _findSafeRoute,
                    child: const Text("Find Safe Route"),
                  ),
                ),
              ],
            ),
    );
  }
}
