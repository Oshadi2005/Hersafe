import 'dart:async';
import 'package:flutter/material.dart';
import 'fake_call_model.dart';

class FakeCallScreen extends StatefulWidget {
  final FakeCallModel callData;

  const FakeCallScreen({super.key, required this.callData});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool callAnswered = false;
  int secondsLeft = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.callData.callDuration;
  }

  void startCallTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft == 0) {
        t.cancel();
        Navigator.pop(context);
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(widget.callData.callerImage),
              ),
              const SizedBox(height: 20),
              Text(
                widget.callData.callerName,
                style: const TextStyle(color: Colors.white, fontSize: 26),
              ),
              const SizedBox(height: 10),
              Text(
                callAnswered ? "00:$secondsLeft" : "Incoming Call…",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 50),

              // Call buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!callAnswered)
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      onPressed: () => Navigator.pop(context),
                      child: const Icon(Icons.call_end),
                    ),
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () {
                      setState(() => callAnswered = true);
                      startCallTimer();
                    },
                    child: Icon(callAnswered ? Icons.volume_up : Icons.call),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
