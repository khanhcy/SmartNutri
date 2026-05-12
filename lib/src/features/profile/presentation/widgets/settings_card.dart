import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/notification_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final notif = context.read<NotificationService>();

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.sm, top: AppSpacing.xs, bottom: AppSpacing.xs),
            child: Text(
              'Tùy chỉnh',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            secondary: Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined,
            ),
            title: const Text('Dark mode'),
            subtitle:
                Text(settings.isDarkMode ? 'Giao diện tối' : 'Giao diện sáng'),
            value: settings.isDarkMode,
            onChanged: settings.setDarkMode,
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            secondary: const Icon(Icons.water_drop_outlined),
            title: const Text('Nhắc uống nước'),
            subtitle: const Text('Mỗi 2 tiếng từ 7h–21h'),
            value: settings.waterRemindersEnabled,
            onChanged: (enabled) async {
              final granted = await notif.requestPermission();
              if (!granted) return;
              await settings.setWaterReminders(enabled);
              if (enabled) {
                await notif.scheduleWaterReminders();
              } else {
                await notif.cancelWaterReminders();
              }
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            secondary: const Icon(Icons.restaurant_outlined),
            title: const Text('Nhắc nhở bữa ăn'),
            subtitle: const Text('Sáng 7:30 • Trưa 12:00 • Tối 18:30'),
            value: settings.mealRemindersEnabled,
            onChanged: (enabled) async {
              final granted = await notif.requestPermission();
              if (!granted) return;
              await settings.setMealReminders(enabled);
              if (enabled) {
                await notif.scheduleMealReminders();
              } else {
                await notif.cancelMealReminders();
              }
            },
          ),
        ],
      ),
    );
  }
}
