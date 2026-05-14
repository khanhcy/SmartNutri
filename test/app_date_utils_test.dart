import 'package:flutter_test/flutter_test.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.toDateStr', () {
    test('formats dates as yyyy-MM-dd with zero-padded month and day', () {
      final date = DateTime(2026, 5, 4, 23, 59);

      expect(AppDateUtils.toDateStr(date), '2026-05-04');
    });

    test('does not convert local DateTime to another timezone before formatting', () {
      final date = DateTime(2026, 12, 31, 23, 30);

      expect(AppDateUtils.toDateStr(date), '2026-12-31');
    });
  });

  group('AppDateUtils.isSameDay', () {
    test('returns true for different times on the same calendar day', () {
      final morning = DateTime(2026, 5, 14, 7, 30);
      final evening = DateTime(2026, 5, 14, 22, 15);

      expect(AppDateUtils.isSameDay(morning, evening), isTrue);
    });

    test('returns false for adjacent calendar days', () {
      final lateNight = DateTime(2026, 5, 14, 23, 59);
      final nextMorning = DateTime(2026, 5, 15, 0, 1);

      expect(AppDateUtils.isSameDay(lateNight, nextMorning), isFalse);
    });
  });

  group('AppDateUtils.shortDayVi', () {
    test('returns Vietnamese short weekday labels from Monday to Sunday', () {
      final monday = DateTime(2026, 5, 11);

      expect(AppDateUtils.shortDayVi(monday), 'T2');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 1))), 'T3');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 2))), 'T4');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 3))), 'T5');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 4))), 'T6');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 5))), 'T7');
      expect(AppDateUtils.shortDayVi(monday.add(const Duration(days: 6))), 'CN');
    });
  });
}
