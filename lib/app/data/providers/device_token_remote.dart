import 'package:cloud_firestore/cloud_firestore.dart';

/// Where this install's push target (Firebase Installation ID, FID) is
/// stored, so Cloud Functions can notify one specific user (for example
/// "It's a match!" to the partner).
abstract interface class DeviceTokenRemote {
  Future<void> save({
    required String uid,
    required String fid,
    required String language,
  });
}

/// `users/{uid}/devices/{fid}`: write-only from the app (see rules).
class FirestoreDeviceTokenRemote implements DeviceTokenRemote {
  @override
  Future<void> save({
    required String uid,
    required String fid,
    required String language,
  }) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('devices')
      .doc(fid)
      .set({
        'fid': fid,
        'language': language,
        'updated_at': FieldValue.serverTimestamp(),
      });
}
