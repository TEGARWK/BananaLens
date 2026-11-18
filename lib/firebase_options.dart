import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Generated from google-services.json for project `fruitlens-447e4`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBW8h2EEhN72TiKS4VDHauIQQuqPe_zl_I',
    appId: '1:551802712440:android:75f73e77d421f30c28d88d',
    messagingSenderId: '551802712440',
    projectId: 'fruitlens-447e4',
    storageBucket: 'fruitlens-447e4.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBW8h2EEhN72TiKS4VDHauIQQuqPe_zl_I',
    appId: '1:551802712440:web:75f73e77d421f30c28d88d',
    messagingSenderId: '551802712440',
    projectId: 'fruitlens-447e4',
    storageBucket: 'fruitlens-447e4.firebasestorage.app',
  );
}
