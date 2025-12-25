import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../safe_route/safe_route_screen.dart';
import '../contacts/contacts_list_screen.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import 'location_service.dart';
import 'sos_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = 'Fetching...';
  final LocationService _locationService = LocationService();
  final SosService _sosService = SosService();
  final AuthService _authService = AuthService();

  int _selectedIndex = 0;
  final String selectedContactNumber = '+94712345678';

  // NEW: Safe Route status
  int? _lastSafetyScore;

  @override
  void initState() {
    super.initState();

    _locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() => _currentLocation = location);
      }
    });

    _locationService.getCurrentLocation().then((loc) {
      if (mounted) {
        setState(() => _currentLocation = loc);
      }
    });

    _locationService.startLocationUpdates();
  }

  void _logout() async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  void _sendSOS() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm SOS'),
          content: const Text(
            'Are you sure you want to send an SOS alert? '
            'This will notify your trusted contact immediately.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send SOS'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _sosService.sendSOS(_currentLocation, selectedContactNumber);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContactsListScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS sent! Select a trusted contact for follow-up.'),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send SOS: ${e.toString()}\n'
              'Opening share options instead.',
            ),
          ),
        );
      }
    }
  }

  void _shareLocation() {
    final message = 'My current location: $_currentLocation';
    Share.share(message);
  }

  void _makeCall() async {
    try {
      await _sosService.callEmergency(selectedContactNumber);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _openSafeRoute() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SafeRouteScreen()),
    );

    if (result is int) {
      setState(() => _lastSafetyScore = result);
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        _openSafeRoute();
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContactsListScreen()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  Color _statusColor(int score) {
    if (score >= 15) return Colors.green;
    if (score >= 8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDECEF),
      appBar: AppBar(
        title: const Text('HerSafe'),
        backgroundColor: const Color(0xFF92487A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SOS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  const Text(
                    'Are you in an emergency?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stay connected with HerSafe',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _sendSOS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SEND SOS',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LOCATION CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading:
                    const Icon(Icons.location_on, color: Color(0xFF92487A)),
                title: const Text(
                  'Your Current Location',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_currentLocation),
              ),
            ),

            const SizedBox(height: 20),

            // ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(Icons.edit, 'Edit Contacts', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ContactsListScreen()),
                  );
                }),
                _actionButton(Icons.share_location, 'Share Location', _shareLocation),
                _actionButton(Icons.call, 'Voice Call', _makeCall),
                _actionButton(Icons.map, 'Safe Route', _openSafeRoute),
              ],
            ),

            const SizedBox(height: 30),

            // SAFE ROUTE STATUS CARD
            if (_lastSafetyScore != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(Icons.shield, color: _statusColor(_lastSafetyScore!)),
                  title: const Text(
                    'Safe Route Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Safety Score: $_lastSafetyScore'),
                ),
              ),

            const SizedBox(height: 30),

            // MAP PREVIEW PLACEHOLDER
            GestureDetector(
              onTap: _openSafeRoute,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Tap to open Safe Route',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
            bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: const Color(0xFF92487A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF92487A),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
