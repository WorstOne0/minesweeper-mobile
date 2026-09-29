// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

// Router
import '/router/app_router.dart';
// Controllers
import '/core/controllers/settings_controller.dart';
// Services
import '/services/storage/hive_storage.dart';
// Styles
import '/styles/app_style.dart';
// Widgets
import '/widgets/my_legacy_material.dart';
// Other
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (details) => FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  if (kDebugMode) await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);

  // Not awaited: the first ad is three games away.
  MobileAds.instance.initialize();

  await Hive.initFlutter();
  await Hive.openBox(HiveStorage.boxName);

  FirebaseAnalytics.instance.logAppOpen();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((settings) => settings.theme));

    return MaterialApp.router(
      title: "CodeSweeper",
      debugShowCheckedModeBanner: false,
      theme: AppStyle.of(theme),
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      builder: (context, child) => MyLegacyMaterial(child: child!),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
