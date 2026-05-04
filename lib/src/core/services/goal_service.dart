import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';

class GoalService {
  GoalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<NutritionGoal?> watchGoal(String uid) {
    return _firestore
        .collection('goals')
        .doc(uid)
        .snapshots()
        .map((doc) =>
            doc.exists ? NutritionGoal.fromMap(uid, doc.data()!) : null);
  }

  Future<NutritionGoal?> getGoal(String uid) async {
    final doc = await _firestore.collection('goals').doc(uid).get();
    if (!doc.exists) return null;
    return NutritionGoal.fromMap(uid, doc.data()!);
  }

  Future<void> upsertGoal(NutritionGoal goal) async {
    await _firestore
        .collection('goals')
        .doc(goal.uid)
        .set(goal.toMap(), SetOptions(merge: true));
  }
}
