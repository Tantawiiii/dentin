import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
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
}
