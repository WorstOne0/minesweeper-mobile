// Flutter packages
import 'package:go_router/go_router.dart';

// Router
import '/router/app_routes.dart';
// Pages
import 'pages/best_times_page.dart';

final bestTimesRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.bestTimes, builder: (_, _) => const BestTimesPage()),
];
