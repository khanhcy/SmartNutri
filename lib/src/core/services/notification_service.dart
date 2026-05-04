import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {
  // Background tap handler – navigation happens after app resumes.
}

/// Manages local notifications for water reminders and meal reminders.
class NotificationService {
  static const _channelId = 'smartnutri_reminders';
  static const _channelName = 'SmartNutri Reminders';
  static const _channelDesc = 'Nhắc nhở uống nước và bữa ăn';

  static const int _waterBaseId = 100;
  static const int _mealBaseId = 200;

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Called when the user taps a notification. Receives the route payload.
  void Function(String payload)? onNotificationTap;

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (_) {
      // Fall back to UTC if timezone not found
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );
  }

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      onNotificationTap?.call(payload);
    }
  }

  Future<bool> requestPermission() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      final granted = await androidImpl.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Schedule water reminders every [intervalHours] between [startHour] and [endHour].
  Future<void> scheduleWaterReminders({
    int startHour = 7,
    int endHour = 21,
    int intervalHours = 2,
  }) async {
    await cancelWaterReminders();

    int id = _waterBaseId;
    for (int hour = startHour; hour <= endHour; hour += intervalHours) {
      await _scheduleDailyAt(
        id: id++,
        title: '💧 Uống nước nào!',
        body: 'Đã đến giờ uống nước. Hãy bổ sung ít nhất 200ml nhé!',
        hour: hour,
        minute: 0,
      );
    }
    debugPrint('NotificationService: Đã lên lịch nhắc nhở uống nước.');
  }

  /// Schedule meal reminders for breakfast, lunch, and dinner.
  Future<void> scheduleMealReminders() async {
    await cancelMealReminders();

    const logPayload = '/app/log';
    final meals = [
      (
        id: _mealBaseId,
        title: '🍳 Bữa sáng',
        body: 'Đừng bỏ bữa sáng! Hãy ghi lại bữa ăn của bạn.',
        hour: 7,
        minute: 30,
        payload: logPayload,
      ),
      (
        id: _mealBaseId + 1,
        title: '🍱 Bữa trưa',
        body: 'Đã đến giờ ăn trưa! Đừng quên ghi lại nhé.',
        hour: 12,
        minute: 0,
        payload: logPayload,
      ),
      (
        id: _mealBaseId + 2,
        title: '🍽️ Bữa tối',
        body: 'Bữa tối đây! Ghi lại để theo dõi dinh dưỡng.',
        hour: 18,
        minute: 30,
        payload: logPayload,
      ),
    ];

    for (final meal in meals) {
      await _scheduleDailyAt(
        id: meal.id,
        title: meal.title,
        body: meal.body,
        hour: meal.hour,
        minute: meal.minute,
        payload: meal.payload,
      );
    }
    debugPrint('NotificationService: Đã lên lịch nhắc nhở bữa ăn.');
  }

  Future<void> cancelWaterReminders() async {
    for (int i = _waterBaseId; i < _waterBaseId + 20; i++) {
      await _plugin.cancel(id: i);
    }
  }

  Future<void> cancelMealReminders() async {
    for (int i = _mealBaseId; i < _mealBaseId + 10; i++) {
      await _plugin.cancel(id: i);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> _scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }
}
