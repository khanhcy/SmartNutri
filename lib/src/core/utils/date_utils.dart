/// Shared date utilities for SmartNutri.
abstract final class AppDateUtils {
  /// Returns `'yyyy-MM-dd'` string for Firestore document IDs.
  static String toDateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String todayStr() => toDateStr(DateTime.now());

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Vietnamese short day label: CN, T2 … T7.
  static String shortDayVi(DateTime d) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[d.weekday % 7];
  }
}
