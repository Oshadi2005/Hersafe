import 'package:flutter/material.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  // Example tips — you can replace/add more
  final List<String> _tips = const [
    "Always stay in well-lit areas at night.",
    "Share your location with trusted friends or family.",
    "Avoid using headphones in unfamiliar areas.",
    "Trust your instincts — leave if something feels unsafe.",
    "Keep your phone fully charged and easily accessible.",
    "Know emergency numbers and have them saved.",
    "Walk confidently and stay aware of your surroundings.",
    "Use safety apps or SOS features when needed.",
    "Avoid sharing personal information with strangers.",
    "Plan your route ahead and let someone know your ETA."
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Tips')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _tips.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(
                  _tips[index],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
