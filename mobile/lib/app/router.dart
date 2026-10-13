import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'start_screen.dart';

/// Named routes of the app.
abstract final class AppRoutes {
  static const start = '/';
}

/// Maps route names to screens (Navigator 2.0 is not needed yet; features
/// add their routes here).
abstract final class AppRouter {
  static const initialRoute = AppRoutes.start;

  static final Map<String, WidgetBuilder> _routes = {
    AppRoutes.start: (_) => const StartScreen(),
  };

  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    final builder = _routes[settings.name] ?? (_) => const NotFoundScreen();
    return MaterialPageRoute<Object?>(builder: builder, settings: settings);
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.pageNotFound)),
    );
  }
}
