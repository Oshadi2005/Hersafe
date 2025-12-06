import 'package:url_launcher/url_launcher.dart';

class SosService {
  /// Sends an SOS message via SMS or WhatsApp using the selected contact's number.
  Future<void> sendSOS(String location, String contactNumber) async {
    final message = '🚨 I need help! My current location: $location';

    // SMS first
    final Uri smsUri = Uri.parse('sms:$contactNumber?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        return;
      }

      // WhatsApp fallback (remove +)
      final String cleanNumber = contactNumber.replaceAll('+', '');
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}'
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        return;
      }

      throw Exception('Could not launch SMS or WhatsApp');
    } catch (e) {
      throw Exception('Failed to send SOS: $e');
    }
  }

  /// Initiates a direct call to the selected contact.
  Future<void> callEmergency(String contactNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: contactNumber);

    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Call app not available');
      }
    } catch (e) {
      throw Exception('Failed to initiate call: $e');
    }
  }
}
