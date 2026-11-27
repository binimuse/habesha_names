import 'package:firebase_core/firebase_core.dart';

/// Same Firebase web app as the family-vote page (project habesha-baby-names).
/// These keys identify the project; access is controlled by firestore.rules.
abstract final class AdminFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfapJPuLyicDwtO6N35ySEeCG0APWYHZ8',
    appId: '1:264352122963:web:8449996636762e22bc1ea6',
    messagingSenderId: '264352122963',
    projectId: 'habesha-baby-names',
    authDomain: 'habesha-baby-names.firebaseapp.com',
    storageBucket: 'habesha-baby-names.firebasestorage.app',
  );
}
