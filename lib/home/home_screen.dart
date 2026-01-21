import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../contacts/trusted_contact_model.dart';
import '../contacts/contacts_list_screen.dart';
import '../safe_route/safe_route_screen.dart';
import '../helpline/helpline_screen.dart';
import '../location_share/location_share_screen.dart';
import 'sos_service.dart';

import '../fake_call/fake_call_service.dart';
import '../fake_call/fake_call_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final SosService _sosService = SosService();

  String _userName = '';
  bool _isLoadingName = true; // Loading indicator

  final String _currentLocation =
      'https://www.google.com/maps?q=6.9186379,79.861248';

  final List<TrustedContact> _trustedContacts = [
    TrustedContact(name: 'Mom', phone: '+94712345678'),
    TrustedContact(name: 'Best Friend', phone: '+94771234567'),
  ];

  late AnimationController _sosController;

  @override
  void initState() {
    super.initState();

    _sosController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final name = await _authService.getCurrentUserName();
    if (!mounted) return;
    setState(() {
      _userName = name;
      _isLoadingName = false; // Finished loading
    });
  }

  @override
  void dispose() {
    _sosController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<bool> _confirmSOS() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Send SOS'),
            content: const Text(
                'This will send your live location to trusted contacts. Continue?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _sendSOS() async {
    final confirmed = await _confirmSOS();
    if (!confirmed) return;

    await _sosService.sendSOS(
      location: _currentLocation,
      contacts: _trustedContacts,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS sent successfully')),
    );
  }

  void _triggerFakeCall() {
    final callData = FakeCallModel(
      callerName: "Best Friend",
      callerImage: "assets/Images/helpline/women.png",
      callDuration: 40,
    );

    FakeCallService.triggerInstantCall(context, callData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF5FA2), Color(0xFFFF2F92)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 38,
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?img=47'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLoadingName
                        ? 'Loading...'
                        : 'Welcome, $_userName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔴 ANIMATED SOS
            GestureDetector(
              onTap: _sendSOS,
              child: AnimatedBuilder(
                animation: _sosController,
                builder: (context, child) {
                  final scale = 1 + (_sosController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.25),
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 35),

            // FEATURES GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _featureCard(
                    icon: Icons.contacts,
                    color: Colors.purple,
                    title: 'Trusted Contacts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ContactsListScreen()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.location_on,
                    color: Colors.green,
                    title: 'Location Sharing',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LocationShareScreen()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.directions_walk,
                    color: Colors.blue,
                    title: 'Safe Route',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SafeRouteScreen()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.support_agent,
                    color: Colors.orange,
                    title: 'Helplines',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HelplineScreen()),
                    ),
                  ),
                  _featureCard(
                    icon: Icons.phone_in_talk,
                    color: Colors.pink,
                    title: 'Fake Call',
                    onTap: _triggerFakeCall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
