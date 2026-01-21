import 'package:flutter/material.dart';
import 'fake_call_model.dart';
import 'fake_call_service.dart';

class FakeCallSettings extends StatelessWidget {
  const FakeCallSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final FakeCallModel callData = FakeCallModel(
      callerName: "Best Friend",
      callerImage: "assets/Images/helpline/women.png",
      callDuration: 40,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Fake Call Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text("Trigger Fake Call Now"),
              onPressed: () {
                FakeCallService.triggerInstantCall(context, callData);
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text("Schedule Fake Call in 10s"),
              onPressed: () {
                FakeCallService.scheduleFakeCall(
                  context,
                  callData,
                  const Duration(seconds: 10),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

