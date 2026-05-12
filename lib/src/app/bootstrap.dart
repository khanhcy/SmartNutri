import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/auth_flow_notifier.dart';
import 'package:smartnutri/src/app/smartnutri_app.dart';
import 'package:smartnutri/src/core/config/app_environment.dart';
import 'package:smartnutri/src/core/firebase/firebase_options.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/ai_food_service.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/barcode_service.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/notification_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/services/recent_foods_service.dart';
import 'package:smartnutri/src/core/services/water_service.dart';
import 'package:smartnutri/src/core/services/weight_service.dart';

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
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } else {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
  }
  // ────────────────────────────────────────────────────────────────────────

  final environment = AppEnvironment.fromDartDefines();
  final settings = await AppSettingsProvider.create();
  final recentFoods = await RecentFoodsService.create();

  final authService = AuthService();
  final profileService = ProfileService();
  final foodService = FoodService();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: environment),
        Provider.value(value: authService),
        Provider.value(value: profileService),
        Provider.value(value: foodService),
        Provider(create: (_) => GoalService()),
        Provider(create: (_) => MealService()),
        Provider(create: (_) => WaterService()),
        Provider(create: (_) => WeightService()),
        Provider(create: (_) => ConnectivityService()),
        Provider(create: (_) => AiFoodService(foodService: foodService)),
        Provider(create: (_) => BarcodeService()),
        Provider.value(value: notificationService),
        ChangeNotifierProvider.value(value: recentFoods),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (_) =>
              AuthFlowNotifier(authService, profileService),
        ),
      ],
      child: const SmartNutriApp(),
    ),
  );
}
