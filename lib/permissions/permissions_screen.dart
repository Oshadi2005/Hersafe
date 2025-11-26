import 'package:flutter/material.dart';
import 'permissions_service.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PermissionsService _permissionsService = PermissionsService();

  bool _locationGranted = false;
  bool _smsGranted = false;
  bool _phoneGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    final location = await _permissionsService.isPermissionGranted(Permission.location);
    final sms = await _permissionsService.isPermissionGranted(Permission.sms);
    final phone = await _permissionsService.isPermissionGranted(Permission.phone);

    setState(() {
      _locationGranted = location;
      _smsGranted = sms;
      _phoneGranted = phone;
    });
  }

  void _requestPermissions() async {
    final allGranted = await _permissionsService.requestAllPermissions();
    _checkPermissions();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allGranted
            ? 'All permissions granted ✅'
            : 'Some permissions are still denied ❌'),
      ),
    );
  }

  Widget _permissionStatus(String name, bool granted) {
    return ListTile(
      title: Text(name),
      trailing: Icon(
        granted ? Icons.check_circle : Icons.cancel,
        color: granted ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Permissions')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _permissionStatus('Location', _locationGranted),
            _permissionStatus('SMS', _smsGranted),
            _permissionStatus('Phone/Call', _phoneGranted),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
