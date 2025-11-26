import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  // Request phone/call permission
  Future<bool> requestPhonePermission() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  // Request all required permissions at once
  Future<bool> requestAllPermissions() async {
    final locationGranted = await requestLocationPermission();
    final smsGranted = await requestSmsPermission();
    final phoneGranted = await requestPhonePermission();

    return locationGranted && smsGranted && phoneGranted;
  }

  // Check if permission is already granted
  Future<bool> isPermissionGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }
}
