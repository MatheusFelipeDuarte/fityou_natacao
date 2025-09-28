// Placeholder gerado manualmente. Substitua por arquivo real usando:
// flutter pub add firebase_core firebase_auth cloud_firestore
// dart pub global activate flutterfire_cli
// flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbK1kh6J2smJm7OpPRHSyvTsfmBZ4sSaA',
    appId: '1:722099956137:web:05ce37ef06dfd9be1b3cb8',
    messagingSenderId: '722099956137',
    projectId: 'fit-swim-app',
    authDomain: 'fit-swim-app.firebaseapp.com',
    storageBucket: 'fit-swim-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxX6LUok0gWIQDblm4VcOiSP-jJlf194s',
    appId: '1:722099956137:android:bfc5a362db0d69ed1b3cb8',
    messagingSenderId: '722099956137',
    projectId: 'fit-swim-app',
    storageBucket: 'fit-swim-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVVLNcJLqeKyycv43Kcc-w297SVySGCGI',
    appId: '1:722099956137:ios:38d37f2c8f8a2dab1b3cb8',
    messagingSenderId: '722099956137',
    projectId: 'fit-swim-app',
    storageBucket: 'fit-swim-app.firebasestorage.app',
    iosBundleId: 'com.example.fityouNatacao',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}