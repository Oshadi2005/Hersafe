import 'dart:async';
import 'package:flutter/material.dart';
import 'fake_call.dart';
import 'fake_call_model.dart';

class FakeCallService {
  // Trigger an instant fake call
  static void triggerInstantCall(
      BuildContext context, FakeCallModel callData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => FakeCallScreen(callData: callData),
      ),
    );
  }

  // Schedule a fake call after a delay
  static void scheduleFakeCall(
      BuildContext context, FakeCallModel callData, Duration delay) {
    Timer(delay, () {
      triggerInstantCall(context, callData);
    });
  }

  // Auto fake call for SOS
  static void autoCallOnSOS(BuildContext context) {
    triggerInstantCall(
      context,
      FakeCallModel(
        callerName: "Mom",
        callerImage: "assets/Images/man.jpg",
        callDuration: 30,
      ),
    );
  }
}
