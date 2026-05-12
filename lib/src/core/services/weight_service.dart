import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';

class WeightService {
  WeightService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String date) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('weight_log')
          .doc(date);

  Stream<double?> watchWeightKg(String uid, String date) {
    return _doc(uid, date).snapshots().map(
          (s) => (s.data()?['weightKg'] as num?)?.toDouble(),
        );
  }

  Future<double?> getWeightKg(String uid, String date) async {
    final snap = await _doc(uid, date).get();
    return (snap.data()?['weightKg'] as num?)?.toDouble();
  }

  Future<void> setWeightKg(String uid, String date, double kg) async {
    await _doc(uid, date).set(
      {'weightKg': kg},
      SetOptions(merge: true),
    );
  }

  /// Most recent [days] calendar days ending today; map dateStr -> kg (only days with data).
  Future<Map<String, double>> getWeightsLastDays({
    required String uid,
    int days = 7,
  }) async {
    final out = <String, double>{};
    final base = DateTime.now();
    final today = DateTime(base.year, base.month, base.day);
    for (var i = 0; i < days; i++) {
      final d = today.subtract(Duration(days: i));
      final key = AppDateUtils.toDateStr(d);
      final kg = await getWeightKg(uid, key);
      if (kg != null) out[key] = kg;
    }
    return out;
  }
}
