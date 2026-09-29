// Flutter packages
import 'package:go_router/go_router.dart';

// Router
import '/router/app_routes.dart';
// Pages
import 'pages/game_page.dart';

final gameRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.game, builder: (_, _) => const GamePage()),
];
