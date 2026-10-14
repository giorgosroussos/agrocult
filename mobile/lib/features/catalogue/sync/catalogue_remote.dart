import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_problem.dart';
import '../../../core/config/app_config.dart';

/// The current catalogue snapshot on the server
/// (`GET /api/v1/catalogue/version`).
class RemoteCatalogueVersion {
  const RemoteCatalogueVersion({
    required this.version,
    required this.schemaVersion,
    required this.builtAt,
    required this.size,
    required this.sha256,
  });

  /// Parses the version response; throws [FormatException] when a field is
  /// missing or has the wrong type.
  factory RemoteCatalogueVersion.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('catalogue version: not an object');
    }
    T field<T>(String name) {
      final value = json[name];
      if (value is! T) {
        throw FormatException('catalogue version: invalid $name');
      }
      return value;
    }

    final builtAt = DateTime.tryParse(field<String>('built_at'));
    final sha256 = field<String>('sha256').toLowerCase();
    if (builtAt == null) {
      throw const FormatException('catalogue version: invalid built_at');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256)) {
      throw const FormatException('catalogue version: invalid sha256');
    }
    return RemoteCatalogueVersion(
      version: field<int>('version'),
      schemaVersion: field<int>('schema_version'),
      builtAt: builtAt.toUtc(),
      size: field<int>('size'),
      sha256: sha256,
    );
  }

  final int version;
  final int schemaVersion;
  final DateTime builtAt;
  final int size;
  final String sha256;
}

/// Where the app gets new catalogue snapshots from (CMP-Catalogue's public
/// sync API, FLOW-003).
abstract interface class CatalogueRemote {
  /// The server's current snapshot, or null when none was published yet.
  Future<RemoteCatalogueVersion?> fetchVersion();

  /// Downloads snapshot [version] into [target] (overwritten).
  Future<void> download(int version, File target);
}

/// [CatalogueRemote] over the backend REST API. No account is needed.
class HttpCatalogueRemote implements CatalogueRemote {
  HttpCatalogueRemote({
    required this._api,
    required AppConfig config,
    HttpClientAdapter? httpClientAdapter,
  }) : _downloads = Dio(
         BaseOptions(
           // The snapshot is fetched from the configured API, never from a
           // URL taken out of a response.
           baseUrl: config.apiV1Url.toString(),
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 60),
         ),
       ) {
    if (httpClientAdapter != null) {
      _downloads.httpClientAdapter = httpClientAdapter;
    }
  }

  final ApiClient _api;
  final Dio _downloads;

  @override
  Future<RemoteCatalogueVersion?> fetchVersion() async {
    try {
      final response = await _api.get('catalogue/version');
      return RemoteCatalogueVersion.fromJson(response.data);
    } on ApiProblem catch (e) {
      if (e.kind == ApiProblemKind.notFound) return null;
      rethrow;
    }
  }

  @override
  Future<void> download(int version, File target) async {
    try {
      await _downloads.download('catalogue/snapshots/$version', target.path);
    } on DioException catch (e) {
      final response = e.response;
      throw ApiProblem.fromResponse(response?.statusCode, null);
    }
  }
}
