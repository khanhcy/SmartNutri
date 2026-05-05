import 'package:cloud_firestore/cloud_firestore.dart';

class WaterService {
  WaterService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String date) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('daily_stats')
          .doc(date);

  Stream<double> watchWaterMl(String uid, String date) {
    return _doc(uid, date).snapshots().map(
          (doc) => (doc.data()?['waterMl'] as num?)?.toDouble() ?? 0.0,
        );
  }

  Future<void> addWaterMl(String uid, String date, double ml) async {
    await _doc(uid, date).set(
      {'waterMl': FieldValue.increment(ml)},
      SetOptions(merge: true),
    );
  }

  Future<void> setWaterMl(String uid, String date, double ml) async {
    await _doc(uid, date).set(
      {'waterMl': ml},
      SetOptions(merge: true),
    );
  }

  Future<double> getWaterMl(String uid, String date) async {
    final snap = await _doc(uid, date).get();
    return (snap.data()?['waterMl'] as num?)?.toDouble() ?? 0.0;
  }
}
