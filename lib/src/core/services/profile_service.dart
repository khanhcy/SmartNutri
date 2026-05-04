import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class ProfileService {
  ProfileService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<UserProfile?> watchProfile(String uid) {
    return _firestore
        .collection('profiles')
        .doc(uid)
        .snapshots()
        .map((doc) =>
            doc.exists ? UserProfile.fromMap(uid, doc.data()!) : null);
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _firestore.collection('profiles').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    return UserProfile.fromMap(uid, data);
  }

  Future<void> upsertProfile(UserProfile profile) async {
    await _firestore
        .collection('profiles')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }
}
