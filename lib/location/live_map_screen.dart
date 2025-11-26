import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../home/location_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();
  LatLng _currentLatLng = const LatLng(0, 0);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Get initial location
    _locationService.getCurrentLocation().then((loc) {
      final parts = loc.split(','); // "lat, lng"
      final lat = double.tryParse(parts[0]) ?? 0;
      final lng = double.tryParse(parts[1]) ?? 0;
      setState(() {
        _currentLatLng = LatLng(lat, lng);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLatLng,
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
      });
      _moveCamera(_currentLatLng);
    });

    // Listen to live location
    _locationService.locationStream.listen((loc) {
      final parts = loc.split(',');
      final lat = double.tryParse(parts[0]) ?? 0;
      final lng = double.tryParse(parts[1]) ?? 0;
      final newLatLng = LatLng(lat, lng);

      setState(() {
        _currentLatLng = newLatLng;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLatLng,
            infoWindow: const InfoWindow(title: 'You are here'),
          ),
        );
      });

      _moveCamera(newLatLng);
    });

    _locationService.startLocationUpdates();
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Location Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLatLng,
          zoom: 16,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
