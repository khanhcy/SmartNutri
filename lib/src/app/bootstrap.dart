import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/smartnutri_app.dart';
import 'package:smartnutri/src/core/config/app_environment.dart';
import 'package:smartnutri/src/core/firebase/firebase_options.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final environment = AppEnvironment.fromDartDefines();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: environment),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => ProfileService()),
        Provider(create: (_) => GoalService()),
        Provider(create: (_) => MealService()),
        Provider(create: (_) => FoodService()),
        Provider(create: (_) => WaterService()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
      ],
      child: const SmartNutriApp(),
    ),
  );
}
