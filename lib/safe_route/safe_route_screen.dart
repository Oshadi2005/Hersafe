import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'safe_route_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  GoogleMapController? _controller;
  final SafeRouteService safeRouteService = SafeRouteService();

  LatLng? start;
  LatLng? end;

  final TextEditingController destinationController = TextEditingController();
  final Map<String, Polyline> _modePolylines = {};
  final Map<String, double> _profileDurationsSeconds = {};

  Marker? _currentMarker;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  Future<void> _setCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Location services are disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Location permission permanently denied. Enable in settings.');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      start = LatLng(position.latitude, position.longitude);
      _currentMarker = Marker(
        markerId: const MarkerId('me'),
        position: start!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'You'),
      );
    });

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(start!, 14));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<LatLng?> _geocodePlace(String place) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(place)}&format=json&limit=1');
    final res = await http.get(url, headers: {
      'User-Agent': 'HerSafeApp/1.0',
      'Accept': 'application/json',
    });
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    if (data is List && data.isNotEmpty) {
      final lat = double.tryParse(data[0]['lat'] ?? '');
      final lon = double.tryParse(data[0]['lon'] ?? '');
      if (lat != null && lon != null) return LatLng(lat, lon);
    }
    return null;
  }

  Future<void> _loadRoutes() async {
    if (start == null || end == null) {
      _showSnack('Set start and destination first');
      return;
    }

    final routes = await safeRouteService.fetchRoutes(start!, end!);
    if (routes.isEmpty) {
      _showSnack('No routes returned');
      return;
    }

    final Map<String, Polyline> newPolylines = {};
    final Map<String, double> durations = {};

    for (final route in routes) {
      final id = 'route_${route.profile}';
      newPolylines[id] = Polyline(
        polylineId: PolylineId(id),
        points: route.points,
        color: Colors.blue,
        width: 6,
      );
      durations[route.profile] = route.duration;
    }

    setState(() {
      _modePolylines
        ..clear()
        ..addAll(newPolylines);
      _profileDurationsSeconds
        ..clear()
        ..addAll(durations);
    });

    final allPoints = [
      if (start != null) start!,
      if (end != null) end!,
      for (final pl in _modePolylines.values) ...pl.points,
    ];
    if (allPoints.isNotEmpty) {
      final bounds = _boundsFromLatLngList(allPoints);
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String _minutesLabel(String profile) {
    final secs = _profileDurationsSeconds[profile];
    if (secs == null) return '-- mins';
    final mins = (secs / 60).round();
    return '$mins mins';
  }

  @override
  Widget build(BuildContext context) {
    final markersSet = {
      if (_currentMarker != null) _currentMarker!,
      if (end != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: end!,
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Safe Route')),
      body: Stack(
        children: [
          if (start != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: start!, zoom: 14),
              polylines: Set<Polyline>.from(_modePolylines.values),
              markers: markersSet,
              onMapCreated: (c) => _controller = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: destinationController,
                        decoration: const InputDecoration(
                          hintText: 'Enter destination',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onSubmitted: (value) async {
                          final coords = await _geocodePlace(value.trim());
                          if (coords != null) {
                            setState(() => end = coords);
                            await _loadRoutes();
                          } else {
                            _showSnack('Destination not found');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final coords = await _geocodePlace(destinationController.text.trim());
                        if (coords != null) {
                          setState(() => end = coords);
                          await _loadRoutes();
                          _showSnack('Destination set and routes loaded!');
                        } else {
                          _showSnack('Destination not found');
                        }
                      },
                      child: const Text('Get Routes'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Mode tiles showing travel times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ModeTile(
                      label: 'Car',
                      minutes: _minutesLabel('driving-car'),
                      color: Colors.blue,
                      onTap: () {
                        final pl = _modePolylines['route_driving-car'];
                        if (pl != null && pl.points.isNotEmpty) {
                          final bounds = _boundsFromLatLngList(pl.points);
                          _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                        }
                      },
                    ),
                    _ModeTile(
                      label: 'Bike',
                      minutes: _minutesLabel('cycling-regular'),
                      color: Colors.green,
                      onTap: () {
                        final pl = _modePolylines['route_cycling-regular'];
                        if (pl != null && pl.points.isNotEmpty) {
                          final bounds = _boundsFromLatLngList(pl.points);
                          _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                        }
                      },
                    ),
                    _ModeTile(
                      label: 'Walking',
                      minutes: _minutesLabel('foot-walking'),
                      color: Colors.orange,
                      onTap: () {
                        final pl = _modePolylines['route_foot-walking'];
                        if (pl != null && pl.points.isNotEmpty) {
                          final bounds = _boundsFromLatLngList(pl.points);
                          _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showSnack('Journey started (tracking not implemented yet)');
                        },
                        child: const Text('Start Journey'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (start != null) {
                            Clipboard.setData(ClipboardData(
                              text: 'My location: ${start!.latitude},${start!.longitude}',
                            ));
                            _showSnack('Location copied to clipboard');
                          }
                        },
                        child: const Text('Share Location'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showSnack('Volunteers feature coming soon');
                        },
                        child: const Text('Volunteers'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String label;
  final String minutes;
  final Color color;
  final VoidCallback onTap;

  const _ModeTile({
    required this.label,
    required this.minutes,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(minutes),
          ],
        ),
      ),
    );
  }
}
