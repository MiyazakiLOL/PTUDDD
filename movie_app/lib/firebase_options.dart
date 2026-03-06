// GENERATED FILE (template)
// Replace the values below with those from your Firebase project or
// run `flutterfire configure` to generate a complete `firebase_options.dart`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // NOTE: This is a small template. Replace with real values.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError('DefaultFirebaseOptions not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVf6RkuK-4JeB4rpSu7nw1r5bB9EymtjE',
    appId: '1:3356489440:android:826819760d150361de8285',
    messagingSenderId: '3356489440',
    projectId: 'movie-841c8',
    storageBucket: 'movie-841c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVf6RkuK-4JeB4rpSu7nw1r5bB9EymtjE',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '3356489440',
    projectId: 'movie-841c8',
    storageBucket: 'movie-841c8.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVf6RkuK-4JeB4rpSu7nw1r5bB9EymtjE',
    appId: '1:3356489440:web:replace_with_windows_appid',
    messagingSenderId: '3356489440',
    projectId: 'movie-841c8',
    storageBucket: 'movie-841c8.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVf6RkuK-4JeB4rpSu7nw1r5bB9EymtjE',
    appId: '1:3356489440:macos:replace_with_macos_appid',
    messagingSenderId: '3356489440',
    projectId: 'movie-841c8',
    storageBucket: 'movie-841c8.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDVf6RkuK-4JeB4rpSu7nw1r5bB9EymtjE',
    appId: '1:3356489440:linux:replace_with_linux_appid',
    messagingSenderId: '3356489440',
    projectId: 'movie-841c8',
    storageBucket: 'movie-841c8.firebasestorage.app',
  );
}
