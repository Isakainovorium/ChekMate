// File generated using FlutterFire CLI.
// ignore_for_file: type=lint
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJ1KQOw3dXeRGOhZVcpN6MgPs9OZYp5jc',
    appId: '1:209000668199:android:YOUR_ANDROID_APP_ID',
    messagingSenderId: '209000668199',
    projectId: 'chekmate-a0423',
    storageBucket: 'chekmate-a0423.firebasestorage.app',
    androidClientId: '209000668199-6sq6qle5682ajdniokvgpc6oq4poec4d.apps.googleusercontent.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJ1KQOw3dXeRGOhZVcpN6MgPs9OZYp5jc',
    appId: '1:209000668199:ios:c6c7680afe597e441ac202',
    messagingSenderId: '209000668199',
    projectId: 'chekmate-a0423',
    storageBucket: 'chekmate-a0423.firebasestorage.app',
    iosBundleId: 'com.chekmate.app',
    iosClientId: '209000668199-ecoboha2cfiui0325p5l74pqbdpc0mgd.apps.googleusercontent.com',
  );
}

