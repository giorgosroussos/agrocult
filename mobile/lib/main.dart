import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/app_config.dart';
import 'core/providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fails fast when a --dart-define value is missing or invalid.
  final config = AppConfig.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const AgrocultApp(),
    ),
  );
}
