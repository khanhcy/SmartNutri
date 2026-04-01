import 'package:flutter/material.dart';
import 'package:smartnutri/src/features/auth/presentation/auth_gate.dart';

class SmartNutriApp extends StatelessWidget {
  const SmartNutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartNutri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
