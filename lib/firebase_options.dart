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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWrE0ctv2D5NDTy7nabuEwyeYQC0h-rAs',
    appId: '1:867351855665:android:c1da3fd9e9b7c8460e8b10',
    messagingSenderId: '867351855665',
    projectId: 'daily-health-tips-2ec27',
    authDomain: 'daily-health-tips-2ec27.firebaseapp.com',
    storageBucket: 'daily-health-tips-2ec27.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWrE0ctv2D5NDTy7nabuEwyeYQC0h-rAs',
    appId: '1:867351855665:android:c1da3fd9e9b7c8460e8b10',
    messagingSenderId: '867351855665',
    projectId: 'daily-health-tips-2ec27',
    storageBucket: 'daily-health-tips-2ec27.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRXsEFWmsY58iWbgwfO1WHzPrjU2QZAlM',
    appId: '1:867351855665:ios:0866728e511a5d1e0e8b10',
    messagingSenderId: '867351855665',
    projectId: 'daily-health-tips-2ec27',
    storageBucket: 'daily-health-tips-2ec27.firebasestorage.app',
    iosBundleId: 'com.example.dailyHealthTips',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRXsEFWmsY58iWbgwfO1WHzPrjU2QZAlM',
    appId: '1:867351855665:ios:0866728e511a5d1e0e8b10',
    messagingSenderId: '867351855665',
    projectId: 'daily-health-tips-2ec27',
    storageBucket: 'daily-health-tips-2ec27.firebasestorage.app',
    iosClientId: '1:867351855665:ios:0866728e511a5d1e0e8b10',
    iosBundleId: 'com.example.dailyHealthTips',
  );
}
