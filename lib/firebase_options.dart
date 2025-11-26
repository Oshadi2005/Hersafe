// File generated manually based on google-services.json + FlutterFire config
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart'
    show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC79rL03DLghmgM_70keUdmoFveDzL9JeE',
    appId: '1:333003281934:web:5ab83db12b56fad4730e5f',
    messagingSenderId: '333003281934',
    projectId: 'hersafe-e785d',
    authDomain: 'hersafe-e785d.firebaseapp.com',
    storageBucket: 'hersafe-e785d.firebasestorage.app',
    measurementId: 'G-Y6CN1MP8CL',
  );

  // ---------------- WEB ----------------

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9rZsVuqqOxsUspwaVPqDtrs6pAxkcvaM',
    appId: '1:333003281934:android:e29bb8b7ea90ae90730e5f',
    messagingSenderId: '333003281934',
    projectId: 'hersafe-e785d',
    storageBucket: 'hersafe-e785d.firebasestorage.app',
  );

  // ---------------- ANDROID ----------------

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqDOc4KyPxKBojRk1dGMAwKMWyZarL34s',
    appId: '1:333003281934:ios:e3879afec515cef7730e5f',
    messagingSenderId: '333003281934',
    projectId: 'hersafe-e785d',
    storageBucket: 'hersafe-e785d.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  // ---------------- iOS ----------------

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqDOc4KyPxKBojRk1dGMAwKMWyZarL34s',
    appId: '1:333003281934:ios:e3879afec515cef7730e5f',
    messagingSenderId: '333003281934',
    projectId: 'hersafe-e785d',
    storageBucket: 'hersafe-e785d.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  // ---------------- macOS ----------------

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC79rL03DLghmgM_70keUdmoFveDzL9JeE',
    appId: '1:333003281934:web:c175fb494173ff4b730e5f',
    messagingSenderId: '333003281934',
    projectId: 'hersafe-e785d',
    authDomain: 'hersafe-e785d.firebaseapp.com',
    storageBucket: 'hersafe-e785d.firebasestorage.app',
    measurementId: 'G-WF1LK8X2YV',
  );

  // ---------------- WINDOWS ----------------
}