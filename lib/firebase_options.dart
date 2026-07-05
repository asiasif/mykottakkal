// File: lib/firebase_options.dart
// File generated manually based on android/app/google-services.json details

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAZ2E1Z36OTCQa1RqB_nCSej6M5sti1t8Q',
    appId: '1:1065335217306:web:d261e479d20c5717ec9323', // Standard placeholder, user can replace this with their actual Firebase Web App ID if needed
    messagingSenderId: '1065335217306',
    projectId: 'mykottakkal-84008',
    authDomain: 'mykottakkal-84008.firebaseapp.com',
    storageBucket: 'mykottakkal-84008.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAZ2E1Z36OTCQa1RqB_nCSej6M5sti1t8Q',
    appId: '1:1065335217306:android:65df778c9b965fc6ec9323',
    messagingSenderId: '1065335217306',
    projectId: 'mykottakkal-84008',
    storageBucket: 'mykottakkal-84008.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZ2E1Z36OTCQa1RqB_nCSej6M5sti1t8Q',
    appId: '1:1065335217306:ios:e5fbe7e0e5a952c4ec9323', // Placeholder for iOS app configuration
    messagingSenderId: '1065335217306',
    projectId: 'mykottakkal-84008',
    storageBucket: 'mykottakkal-84008.firebasestorage.app',
    iosBundleId: 'com.kottakkal.mykottakkal',
  );
}
