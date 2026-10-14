import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_client.dart';
import 'auth/auth_repository.dart';
import 'auth/auth_session.dart';
import 'auth/device_id.dart';
import 'auth/token_storage.dart';
import 'config/app_config.dart';
import 'db/app_database.dart';

/// App configuration; read from `--dart-define` values.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);

/// Storage of this device's API token.
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

/// Stable id of this app installation (one API token per device).
final deviceIdStorageProvider = Provider<DeviceIdStorage>(
  (ref) => SecureDeviceIdStorage(),
);

/// Client for the backend REST API.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    config: ref.watch(appConfigProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

/// Local database; closed when the provider is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

/// Account endpoints (sign-up, sign-in, password reset, sign-out).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    api: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    deviceIdStorage: ref.watch(deviceIdStorageProvider),
  ),
);

/// Whether this device is signed in.
final authSessionProvider = AsyncNotifierProvider<AuthSession, bool>(
  AuthSession.new,
  // A failing keystore read is not retried in a loop.
  retry: (_, _) => null,
);
