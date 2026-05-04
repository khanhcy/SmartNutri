import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/auth_flow_notifier.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/notification_service.dart';
import 'package:smartnutri/src/core/ui/components/offline_banner.dart';
import 'package:smartnutri/src/core/ui/theme/app_theme.dart';

class SmartNutriApp extends StatefulWidget {
  const SmartNutriApp({super.key});

  @override
  State<SmartNutriApp> createState() => _SmartNutriAppState();
}

class _SmartNutriAppState extends State<SmartNutriApp> {
  late final _router = createAppRouter(
    authFlow: context.read<AuthFlowNotifier>(),
  );

  @override
  void initState() {
    super.initState();
    // Wire notification taps to GoRouter navigation.
    context.read<NotificationService>().onNotificationTap = (payload) {
      _router.go(payload);
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return MaterialApp.router(
      title: 'SmartNutri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      routerConfig: _router,
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
