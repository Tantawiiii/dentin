import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseConfig {
  /// Returns FirebaseOptions for the current platform.
  /// 
  /// - iOS: Returns explicit options from GoogleService-Info.plist
  /// - Android: Returns null to auto-detect from google-services.json
  /// - Web: Returns explicit options (required for web)
  static FirebaseOptions? get currentPlatform {
    // On iOS, use explicit options from GoogleService-Info.plist
    // This ensures Firebase initializes correctly
    if (Platform.isIOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDwpUzaq3hd_o8ERrlfnAXr3-gNmrjaROo',
        appId: '1:721699029637:ios:a74f2ff094befceaea1fec',
        messagingSenderId: '721699029637',
        projectId: 'chat-a3477',
        storageBucket: 'chat-a3477.firebasestorage.app',
        databaseURL: 'https://chat-a3477-default-rtdb.firebaseio.com',
      );
    }
    
    // On Android, let Firebase auto-detect from google-services.json
    if (Platform.isAndroid) {
      return null; // Auto-detect from google-services.json
    }
    
    // On Web, use explicit options (web doesn't have auto-detect)
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDX4XGOyu3dy4wRCrUpoarPPtY6HlGp--k',
        appId: '1:721699029637:web:611a08b476fd5bc6ea1fec',
        messagingSenderId: '721699029637',
        projectId: 'chat-a3477',
        authDomain: 'chat-a3477.firebaseapp.com',
        storageBucket: 'chat-a3477.firebasestorage.app',
        measurementId: 'G-HNGX18QXEW',
        databaseURL: 'https://chat-a3477-default-rtdb.firebaseio.com',
      );
    }
    
    // Default: try to auto-detect
    return null;
  }
}
