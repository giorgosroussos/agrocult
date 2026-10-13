/// Runtime configuration of the app.
///
/// Every external endpoint comes from `--dart-define` (or
/// `--dart-define-from-file`); nothing is hardcoded.
class AppConfig {
  const AppConfig({required this.apiBaseUrl, required this.mapTileUrl});

  /// Reads the compile-time environment.
  factory AppConfig.fromEnvironment() => AppConfig.fromValues(
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    mapTileUrl: const String.fromEnvironment('MAP_TILE_URL'),
  );

  /// Validates raw values; throws [ConfigurationException] when one is
  /// missing or is not an absolute http(s) URL.
  factory AppConfig.fromValues({
    required String apiBaseUrl,
    required String mapTileUrl,
  }) {
    return AppConfig(
      apiBaseUrl: _requireHttpUrl('API_BASE_URL', apiBaseUrl),
      mapTileUrl: _requireHttpUrl('MAP_TILE_URL', mapTileUrl),
    );
  }

  /// Backend origin, without trailing slash (e.g. `https://api.example.org`).
  final Uri apiBaseUrl;

  /// Map tile source used by the garden map.
  final Uri mapTileUrl;

  /// Base URL of the versioned REST API, with trailing slash.
  Uri get apiV1Url => apiBaseUrl.replace(path: '${apiBaseUrl.path}/api/v1/');

  static Uri _requireHttpUrl(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ConfigurationException(
        '$key is not set; pass it with --dart-define',
      );
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      throw ConfigurationException('$key must be an absolute http(s) URL');
    }
    final path = uri.path.endsWith('/')
        ? uri.path.substring(0, uri.path.length - 1)
        : uri.path;
    return uri.replace(path: path);
  }
}

class ConfigurationException implements Exception {
  const ConfigurationException(this.message);

  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}
