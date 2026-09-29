// Flutter packages
import 'package:go_router/go_router.dart';

// Router
import '/router/app_routes.dart';
// Pages
import 'pages/settings_page.dart';

final settingsRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
];
