// Flutter packages
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Features
import '/features/best_times/best_times_routes.dart';
import '/features/game/game_routes.dart';
import '/features/home/home_routes.dart';
import '/features/settings/settings_routes.dart';
// Router
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
    routes: [...homeRoutes, ...gameRoutes, ...bestTimesRoutes, ...settingsRoutes],
  );
});
