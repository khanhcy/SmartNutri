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
