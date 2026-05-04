import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/smartnutri_app.dart';
import 'package:smartnutri/src/core/config/app_environment.dart';
import 'package:smartnutri/src/core/firebase/firebase_options.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/notification_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // ── Crashlytics global error hooks ──────────────────────────────────────
  if (!kDebugMode) {
    // Catch Flutter framework errors
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Catch async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    // In debug mode, still report non-fatal errors for visibility
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
  }
  // ────────────────────────────────────────────────────────────────────────

  final environment = AppEnvironment.fromDartDefines();
  final settings = await AppSettingsProvider.create();

  final notificationService = NotificationService();
  await notificationService.init();

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
        Provider(create: (_) => ConnectivityService()),
        Provider.value(value: notificationService),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const SmartNutriApp(),
    ),
  );
}
