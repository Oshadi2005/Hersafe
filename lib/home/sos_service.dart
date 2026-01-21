import 'package:url_launcher/url_launcher.dart';
import '../contacts/trusted_contact_model.dart';


class SosService {
  Future<void> sendSOS({
    required String location,
    required List<TrustedContact> contacts,
  }) async {
    for (final contact in contacts) {
      final message = Uri.encodeComponent(
        '🚨 SOS ALERT!\n\nI need help.\n📍 My location:\n$location',
      );

      final smsUri = Uri.parse('sms:${contact.phone}?body=$message');

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }
}
