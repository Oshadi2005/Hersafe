import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

class SosService {
  /// Sends an SOS message via SMS app if available. Falls back to share sheet.
  Future<void> sendSOS(String location, String contactNumber) async {
    final message = '🚨 I need help! My current location: $location';

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: contactNumber,
      queryParameters: {'body': message},
    );

    developer.log('Attempting to send SOS. smsUri: $smsUri', name: 'SosService');

    try {
      final canLaunchSms = await canLaunchUrl(smsUri);
      developer.log('canLaunchUrl(smsUri) => $canLaunchSms', name: 'SosService');

      if (canLaunchSms) {
        final launched = await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        developer.log('launchUrl(smsUri) returned $launched', name: 'SosService');

        if (!launched) {
          // launch failed even though canLaunch said true — fallback
          developer.log('launchUrl returned false — falling back to Share', name: 'SosService');
          await Share.share(message);
        }
      } else {
        // No SMS app available — open share sheet so user can choose an app
        developer.log('No handler for SMS intent. Using Share as fallback.', name: 'SosService');
        await Share.share(message);
      }
    } catch (e, st) {
      developer.log('Exception sending SOS: $e\n$st', name: 'SosService', error: e);
      throw Exception('Failed to send SOS: $e');
    }
  }

  Future<void> callEmergency(String contactNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: contactNumber);
    developer.log('Attempting call to $callUri', name: 'SosService');

    try {
      if (await canLaunchUrl(callUri)) {
        final launched = await launchUrl(callUri, mode: LaunchMode.externalApplication);
        if (!launched) throw Exception('Platform failed to launch dialer');
      } else {
        throw Exception('Call app not available');
      }
    } catch (e) {
      developer.log('Exception initiating call: $e', name: 'SosService', error: e);
      throw Exception('Failed to initiate call: $e');
    }
  }
}
