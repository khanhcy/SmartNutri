import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.plan,
    required this.status,
    required this.source,
    this.premiumUntil,
  });

  final String plan;
  final String status;
  final String source;
  final DateTime? premiumUntil;

  static const free = SubscriptionStatus(
    plan: 'free',
    status: 'none',
    source: 'default',
  );

  bool get isPremium {
    if (plan != 'premium' || status != 'active') return false;
    final until = premiumUntil;
    return until == null || until.isAfter(DateTime.now());
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic>? map) {
    if (map == null) return SubscriptionStatus.free;
    return SubscriptionStatus(
      plan: map['plan'] as String? ?? 'free',
      status: map['status'] as String? ?? 'none',
      source: map['source'] as String? ?? 'default',
      premiumUntil: _dateTimeValue(map['premiumUntil']),
    );
  }

  static DateTime? _dateTimeValue(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class AiScanUsage {
  const AiScanUsage({
    required this.used,
    required this.limit,
    required this.monthKey,
  });

  final int used;
  final int limit;
  final String monthKey;

  int get remaining => (limit - used).clamp(0, limit);
  bool get hasQuota => used < limit;

  factory AiScanUsage.fromMap(Map<String, dynamic>? map, String monthKey) {
    return AiScanUsage(
      used: (map?['aiScanUsed'] as num?)?.toInt() ?? 0,
      limit: (map?['aiScanLimit'] as num?)?.toInt() ?? 5,
      monthKey: map?['monthKey'] as String? ?? monthKey,
    );
  }
}

class SubscriptionOverview {
  const SubscriptionOverview({
    required this.subscription,
    required this.aiScanUsage,
  });

  final SubscriptionStatus subscription;
  final AiScanUsage aiScanUsage;

  bool get isPremium => subscription.isPremium;
  bool get canUseAiScan => isPremium || aiScanUsage.hasQuota;
  int get remainingFreeAiScans =>
      isPremium ? aiScanUsage.limit : aiScanUsage.remaining;
}
