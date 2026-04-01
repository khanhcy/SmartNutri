import 'package:flutter/material.dart';
import 'package:smartnutri/src/features/auth/presentation/auth_gate.dart';
import 'package:smartnutri/src/core/ui/theme/app_theme.dart';

class SmartNutriApp extends StatelessWidget {
  const SmartNutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartNutri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const AuthGate(),
    );
  }
}
