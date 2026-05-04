import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/notification_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

/// Bottom sheet hiển thị trạng thái và toggle nhắc nhở.
class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MultiProvider(
        providers: [
          Provider.value(value: context.read<NotificationService>()),
          ChangeNotifierProvider.value(value: context.read<AppSettingsProvider>()),
        ],
        child: const NotificationsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final notif = context.read<NotificationService>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.notifications_outlined, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Nhắc nhở',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bật để nhận thông báo nhắc nhở uống nước và bữa ăn hằng ngày.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // Water reminder toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.water_drop_outlined,
                  color: Colors.blue.shade600, size: 20),
            ),
            title: const Text('Nhắc uống nước'),
            subtitle: const Text('Mỗi 2 tiếng từ 7h đến 21h'),
            value: settings.waterRemindersEnabled,
            onChanged: (enabled) async {
              final granted = await notif.requestPermission();
              if (!granted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Hãy cấp quyền thông báo trong cài đặt thiết bị'),
                  ));
                }
                return;
              }
              await settings.setWaterReminders(enabled);
              if (enabled) {
                await notif.scheduleWaterReminders();
              } else {
                await notif.cancelWaterReminders();
              }
            },
          ),
          const Divider(height: 1),

          // Meal reminder toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant_outlined,
                  color: Colors.orange.shade600, size: 20),
            ),
            title: const Text('Nhắc nhở bữa ăn'),
            subtitle: const Text('Sáng 7:30  •  Trưa 12:00  •  Tối 18:30'),
            value: settings.mealRemindersEnabled,
            onChanged: (enabled) async {
              final granted = await notif.requestPermission();
              if (!granted) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Hãy cấp quyền thông báo trong cài đặt thiết bị'),
                  ));
                }
                return;
              }
              await settings.setMealReminders(enabled);
              if (enabled) {
                await notif.scheduleMealReminders();
              } else {
                await notif.cancelMealReminders();
              }
            },
          ),

          // Status summary
          if (settings.waterRemindersEnabled || settings.mealRemindersEnabled) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _summaryText(settings),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _summaryText(AppSettingsProvider s) {
    if (s.waterRemindersEnabled && s.mealRemindersEnabled) {
      return 'Đang nhắc nhở uống nước và bữa ăn hằng ngày';
    } else if (s.waterRemindersEnabled) {
      return 'Đang nhắc uống nước mỗi 2 tiếng';
    } else {
      return 'Đang nhắc nhở 3 bữa ăn mỗi ngày';
    }
  }
}
