import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/ui/theme/app_theme.dart';
import 'package:smartnutri/src/features/auth/presentation/auth_gate.dart';

class SmartNutriApp extends StatelessWidget {
  const SmartNutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return MaterialApp(
      title: 'SmartNutri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      home: const AuthGate(),
    );
  }
}
