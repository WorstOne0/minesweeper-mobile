// Flutter packages
import 'package:go_router/go_router.dart';

// Router
import '/router/app_routes.dart';
// Pages
import 'pages/home_page.dart';

final homeRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
];
