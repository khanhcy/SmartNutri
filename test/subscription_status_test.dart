import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/services/subscription_service.dart';
import 'package:smartnutri/src/features/subscription/domain/subscription_status.dart';

void main() {
  group('SubscriptionStatus', () {
    test('mặc định là gói free khi thiếu dữ liệu', () {
      final status = SubscriptionStatus.fromMap(null);

      expect(status.plan, 'free');
      expect(status.status, 'none');
      expect(status.source, 'default');
      expect(status.isPremium, isFalse);
    });

    test('premium active không hết hạn được xem là premium', () {
      final status = SubscriptionStatus.fromMap({
        'plan': 'premium',
        'status': 'active',
      });

      expect(status.isPremium, isTrue);
    });

    test('premium đã hết hạn không còn premium', () {
      final status = SubscriptionStatus.fromMap({
        'plan': 'premium',
        'status': 'active',
        'premiumUntil': '2020-01-01T00:00:00.000Z',
      });

      expect(status.isPremium, isFalse);
    });
  });

  group('AiScanUsage', () {
    test('tính đúng lượt scan còn lại', () {
      final usage = AiScanUsage.fromMap({
        'aiScanUsed': 3,
        'aiScanLimit': 5,
      }, '2026-05');

      expect(usage.remaining, 2);
      expect(usage.hasQuota, isTrue);
    });

    test('hết quota khi used bằng limit', () {
      final usage = AiScanUsage.fromMap({
        'aiScanUsed': 5,
        'aiScanLimit': 5,
      }, '2026-05');

      expect(usage.remaining, 0);
      expect(usage.hasQuota, isFalse);
    });
  });

  test('currentUsageMonth format yyyy-MM', () {
    expect(
      SubscriptionService.currentUsageMonth(DateTime(2026, 5, 14)),
      '2026-05',
    );
  });
}
