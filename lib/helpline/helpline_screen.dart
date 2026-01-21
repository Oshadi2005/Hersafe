import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplineScreen extends StatelessWidget {
  const HelplineScreen({super.key});

  // 📞 CALL FUNCTION (REAL CALL)
  Future<void> _makeCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      debugPrint('Could not launch call to $phoneNumber');
      // Optional: Show a SnackBar if call cannot be made
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Cannot call $phoneNumber')),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FA),
      appBar: AppBar(
        title: const Text('Emergency Helplines'),
        backgroundColor: const Color(0xFF92487A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _helplineTile(
            image: 'assets/Images/helpline/police.jpg',
            title: 'Emergency Police',
            number: '118 / 119',
            purpose: 'Immediate danger',
            onCall: () => _makeCall('119'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/ambulance.png',
            title: 'Ambulance / Health Emergency',
            number: '1990',
            purpose: 'Medical emergencies',
            onCall: () => _makeCall('1990'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/abuse.png',
            title: 'Abuse Report Hotline',
            number: '109',
            purpose: 'Women & Child abuse reporting',
            onCall: () => _makeCall('109'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/women.png',
            title: 'Women Helpline (Govt)',
            number: '1938',
            purpose: 'Domestic violence support',
            onCall: () => _makeCall('1938'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/win.png',
            title: 'Women In Need (Support)',
            number: '0775676555',
            purpose: '24/7 violence help',
            onCall: () => _makeCall('0775676555'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/legal.png',
            title: 'WIN Legal Help',
            number: '0768686555',
            purpose: 'Legal aid',
            onCall: () => _makeCall('0768686555'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/mental.png',
            title: 'Mental Health Support',
            number: '1926 / 1333',
            purpose: 'Emotional support',
            onCall: () => _makeCall('1926'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/legal_aid.png',
            title: 'Legal Aid Commission',
            number: '0115335329',
            purpose: 'Free legal advice',
            onCall: () => _makeCall('0115335329'),
          ),
          _helplineTile(
            image: 'assets/Images/helpline/shelter.png',
            title: 'Shelter Support',
            number: '0767516596',
            purpose: 'Safe shelter info',
            onCall: () => _makeCall('0767516596'),
          ),
        ],
      ),
    );
  }

  // 🧩 HELPLINE TILE WIDGET
  Widget _helplineTile({
    required String image,
    required String title,
    required String number,
    required String purpose,
    required VoidCallback onCall,
  }) {
    return Card(
      elevation: 4,
      // ignore: deprecated_member_use
      shadowColor: Colors.pinkAccent.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[200],
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              purpose,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green, size: 28),
          onPressed: onCall,
        ),
      ),
    );
  }
}
