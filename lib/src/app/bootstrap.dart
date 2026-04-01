import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/smartnutri_app.dart';
import 'package:smartnutri/src/core/config/app_environment.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final environment = AppEnvironment.fromDartDefines();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: environment),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ProfileService()),
      ],
      child: const SmartNutriApp(),
    ),
  );
}
