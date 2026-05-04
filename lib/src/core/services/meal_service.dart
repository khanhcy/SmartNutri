import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';

class MealService {
  MealService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const _uuid = Uuid();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('meal_entries');

  Stream<List<MealEntry>> watchEntriesForDate(String uid, String date) {
    // Chỉ filter theo `date` (không orderBy trên server) để tránh cần composite index;
    // sắp xếp theo thời gian ghi ở client.
    return _col(uid)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((q) {
          final list = q.docs
              .map((d) => MealEntry.fromMap(d.id, d.data()))
              .toList()
            ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
          return list;
        });
  }

  Future<List<MealEntry>> getEntriesForDate(String uid, String date) async {
    final q = await _col(uid).where('date', isEqualTo: date).get();
    return q.docs.map((d) => MealEntry.fromMap(d.id, d.data())).toList();
  }

  Future<void> addEntry(String uid, MealEntry entry) async {
    final id = _uuid.v4();
    await _col(uid).doc(id).set(entry.toMap());
  }

  Future<void> updateEntry(String uid, MealEntry entry) async {
    await _col(uid).doc(entry.id).set(entry.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteEntry(String uid, String entryId) async {
    await _col(uid).doc(entryId).delete();
  }
}
