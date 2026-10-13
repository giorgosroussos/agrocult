import 'package:agrocult/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('builds the /api/v1 base from the configured origin', () {
      final config = AppConfig.fromValues(
        apiBaseUrl: 'https://api.example.test/',
        mapTileUrl: 'https://tiles.example.test/planet',
      );

      expect(config.apiBaseUrl.toString(), 'https://api.example.test');
      expect(config.apiV1Url.toString(), 'https://api.example.test/api/v1/');
      expect(config.mapTileUrl.toString(), 'https://tiles.example.test/planet');
    });

    test('keeps a path prefix of the origin', () {
      final config = AppConfig.fromValues(
        apiBaseUrl: 'http://10.0.2.2:8000/backend',
        mapTileUrl: 'https://tiles.example.test',
      );

      expect(
        config.apiV1Url.toString(),
        'http://10.0.2.2:8000/backend/api/v1/',
      );
    });

    test('rejects a missing API_BASE_URL', () {
      expect(
        () => AppConfig.fromValues(
          apiBaseUrl: '',
          mapTileUrl: 'https://tiles.example.test',
        ),
        throwsA(
          isA<ConfigurationException>().having(
            (e) => e.message,
            'message',
            contains('API_BASE_URL'),
          ),
        ),
      );
    });

    test('rejects a missing MAP_TILE_URL', () {
      expect(
        () => AppConfig.fromValues(
          apiBaseUrl: 'https://api.example.test',
          mapTileUrl: '  ',
        ),
        throwsA(
          isA<ConfigurationException>().having(
            (e) => e.message,
            'message',
            contains('MAP_TILE_URL'),
          ),
        ),
      );
    });

    test('rejects values that are not absolute http(s) URLs', () {
      for (final bad in [
        'api.example.test',
        'ftp://api.example.test',
        '/api',
      ]) {
        expect(
          () => AppConfig.fromValues(
            apiBaseUrl: bad,
            mapTileUrl: 'https://tiles.example.test',
          ),
          throwsA(isA<ConfigurationException>()),
          reason: bad,
        );
      }
    });

    test('has no built-in endpoint: without --dart-define it fails', () {
      // The test run passes no --dart-define values.
      expect(AppConfig.fromEnvironment, throwsA(isA<ConfigurationException>()));
    });
  });
}
