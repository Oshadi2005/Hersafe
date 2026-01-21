import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contacts/contacts_service.dart';
import '../contacts/trusted_contact_model.dart';
import 'location_share_service.dart';

class LocationShareScreen extends StatefulWidget {
  const LocationShareScreen({super.key});

  @override
  State<LocationShareScreen> createState() => _LocationShareScreenState();
}

class _LocationShareScreenState extends State<LocationShareScreen> {
  LatLng? _latLng;
  bool _loading = true;

  late ContactsService _contactsService;

  @override
  void initState() {
    super.initState();
    _contactsService = ContactsService();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await LocationShareService.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _latLng = LatLng(pos.latitude, pos.longitude);
      _loading = false;
    });
  }

  void _shareWithAnyone() {
    if (_latLng == null) return;

    final msg = LocationShareService.buildShareMessage(
      _latLng!.latitude,
      _latLng!.longitude,
    );

    Share.share(msg);
  }

  Future<void> _shareWithContacts() async {
    if (_latLng == null) return;

    // ✅ ASYNC – persistent contacts
    final List<TrustedContact> contacts =
        await _contactsService.getContactsAsync();

    if (contacts.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trusted contacts added')),
      );
      return;
    }

    final numbers = contacts
        .where((c) => c.phone.isNotEmpty)
        .map((c) => c.phone)
        .join(',');

    final msg = LocationShareService.buildShareMessage(
      _latLng!.latitude,
      _latLng!.longitude,
    );

    final uri = Uri(
      scheme: 'sms',
      path: numbers,
      queryParameters: {'body': msg},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open SMS app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFF),

      // 🌸 APP BAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('Share My Location'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF5F9E),
                Color(0xFF8B5CF6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // 🗺 MAP
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      height: 260,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _latLng!,
                          zoom: 16,
                        ),
                        myLocationEnabled: true,
                        markers: {
                          Marker(
                            markerId: const MarkerId('me'),
                            position: _latLng!,
                          ),
                        },
                      ),
                    ),
                  ),
                ),

                // 📍 INFO CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Your Live Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Quickly share your real-time location with trusted people when you feel unsafe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 🔘 BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [

                      _gradientButton(
                        icon: Icons.group,
                        text: 'Share with Trusted Contacts',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B5CF6),
                            Color(0xFFFF5F9E),
                          ],
                        ),
                        onTap: _shareWithContacts,
                      ),

                      const SizedBox(height: 14),

                      _gradientButton(
                        icon: Icons.share,
                        text: 'Share with Anyone',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF22C55E),
                            Color(0xFF16A34A),
                          ],
                        ),
                        onTap: _shareWithAnyone,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // 🔘 GRADIENT BUTTON WIDGET
  Widget _gradientButton({
    required IconData icon,
    required String text,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
