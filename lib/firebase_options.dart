// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDKhAXNdxcqDWVrJiNzfLGdTsT9EXr5vCA',
    appId: '1:289951990586:web:2f4b771c8ecb9864714603',
    messagingSenderId: '289951990586',
    projectId: 'spiewnik-pielgrzyma-50fa3',
    authDomain: 'spiewnik-pielgrzyma-50fa3.firebaseapp.com',
    storageBucket: 'spiewnik-pielgrzyma-50fa3.appspot.com',
    measurementId: 'G-98SNGQN713',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZ6h5cTWK3SA670XFxozgjiEbs2d5quZ4',
    appId: '1:289951990586:android:5a12b32fcef13032714603',
    messagingSenderId: '289951990586',
    projectId: 'spiewnik-pielgrzyma-50fa3',
    storageBucket: 'spiewnik-pielgrzyma-50fa3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDmmUCNqT3iDFTZRsDvZA-Pdh2QYlKm4jA',
    appId: '1:289951990586:ios:0a91c78a332989d4714603',
    messagingSenderId: '289951990586',
    projectId: 'spiewnik-pielgrzyma-50fa3',
    storageBucket: 'spiewnik-pielgrzyma-50fa3.appspot.com',
    iosBundleId: 'com.example.spiewnikPielgrzyma',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDmmUCNqT3iDFTZRsDvZA-Pdh2QYlKm4jA',
    appId: '1:289951990586:ios:cde65a3ed2b5acb9714603',
    messagingSenderId: '289951990586',
    projectId: 'spiewnik-pielgrzyma-50fa3',
    storageBucket: 'spiewnik-pielgrzyma-50fa3.appspot.com',
    iosBundleId: 'com.example.spiewnikPielgrzyma.RunnerTests',
  );
}
