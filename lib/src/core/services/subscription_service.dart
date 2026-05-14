import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnutri/src/features/subscription/domain/subscription_status.dart';

class SubscriptionService {
  SubscriptionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<SubscriptionOverview> watchOverview(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((doc) => _overviewFromUserData(uid, doc.data()));
  }

  Future<SubscriptionOverview> getOverview(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    return _overviewFromUserData(uid, userDoc.data());
  }

  Future<SubscriptionOverview> recordAiScanUse(String uid) async {
    final monthKey = currentUsageMonth();
    final userRef = _firestore.collection('users').doc(uid);
    final usageRef = userRef.collection('usage').doc(monthKey);

    return _firestore.runTransaction((tx) async {
      final userDoc = await tx.get(userRef);
      final subscription = SubscriptionStatus.fromMap(
        userDoc.data()?['subscription'] as Map<String, dynamic>?,
      );

      final usageDoc = await tx.get(usageRef);
      final usage = AiScanUsage.fromMap(usageDoc.data(), monthKey);
      if (subscription.isPremium) {
        return SubscriptionOverview(
          subscription: subscription,
          aiScanUsage: usage,
        );
      }

      if (!usage.hasQuota) {
        return SubscriptionOverview(
          subscription: subscription,
          aiScanUsage: usage,
        );
      }

      final nextUsage = {
        'monthKey': monthKey,
        'aiScanUsed': usage.used + 1,
        'aiScanLimit': usage.limit,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      tx.set(usageRef, nextUsage, SetOptions(merge: true));
      tx.set(userRef, {'aiScanUsage': nextUsage}, SetOptions(merge: true));

      return SubscriptionOverview(
        subscription: subscription,
        aiScanUsage: AiScanUsage.fromMap(nextUsage, monthKey),
      );
    });
  }

  Future<SubscriptionOverview> _overviewFromUserData(
    String uid,
    Map<String, dynamic>? userData,
  ) async {
    final monthKey = currentUsageMonth();
    final usageSummary = userData?['aiScanUsage'] as Map<String, dynamic>?;
    final usageData = usageSummary?['monthKey'] == monthKey
        ? usageSummary
        : await _loadUsage(uid, monthKey);

    return SubscriptionOverview(
      subscription: SubscriptionStatus.fromMap(
        userData?['subscription'] as Map<String, dynamic>?,
      ),
      aiScanUsage: AiScanUsage.fromMap(usageData, monthKey),
    );
  }

  Future<Map<String, dynamic>?> _loadUsage(String uid, String monthKey) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('usage')
        .doc(monthKey)
        .get();
    return doc.data();
  }

  static String currentUsageMonth([DateTime? now]) {
    final date = now ?? DateTime.now();
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
