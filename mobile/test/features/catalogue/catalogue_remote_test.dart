import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agrocult/core/api/api_client.dart';
import 'package:agrocult/core/api/api_problem.dart';
import 'package:agrocult/core/config/app_config.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_remote.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/fakes.dart';

/// Answers every request with [status] and [bytes]; records the requests.
class BytesAdapter implements HttpClientAdapter {
  BytesAdapter(
    this.status,
    this.bytes, {
    this.contentType = 'application/json',
  });

  final int status;
  final List<int> bytes;
  final String contentType;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromBytes(
      bytes,
      status,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _version = {
  'version': 7,
  'schema_version': 1,
  'built_at': '2026-10-14T12:00:00Z',
  'size': 4096,
  'sha256': 'bf757a539f4cb314ccec67e64c4d3b6a69c9f6936e974acb588d1675a31132df',
  'download_url': 'https://elsewhere.example.test/api/v1/catalogue/snapshots/7',
};

void main() {
  final config = AppConfig.fromValues(
    apiBaseUrl: 'https://api.example.test',
    mapTileUrl: 'https://tiles.example.test',
  );

  HttpCatalogueRemote remote(
    HttpClientAdapter api, {
    HttpClientAdapter? downloads,
  }) => HttpCatalogueRemote(
    api: ApiClient(
      config: config,
      tokenStorage: InMemoryTokenStorage(),
      httpClientAdapter: api,
    ),
    config: config,
    httpClientAdapter: downloads,
  );

  test('reads the current version without an account', () async {
    final adapter = FakeHttpAdapter(
      response: const FakeResponse(200, body: _version),
    );

    final version = await remote(adapter).fetchVersion();

    final request = adapter.requests.single;
    expect(
      request.uri.toString(),
      'https://api.example.test/api/v1/catalogue/version',
    );
    expect(request.headers['Authorization'], isNull);
    expect(version!.version, 7);
    expect(version.schemaVersion, 1);
    expect(version.builtAt, DateTime.utc(2026, 10, 14, 12));
    expect(version.size, 4096);
    expect(version.sha256, _version['sha256']);
  });

  test('no published snapshot (404) means no version', () async {
    final adapter = FakeHttpAdapter(
      response: const FakeResponse(
        404,
        body: {'title': 'Not Found', 'status': 404},
        contentType: 'application/problem+json',
      ),
    );

    expect(await remote(adapter).fetchVersion(), isNull);
  });

  test('server errors are reported, not hidden', () async {
    final adapter = FakeHttpAdapter(response: const FakeResponse(503));

    await expectLater(
      remote(adapter).fetchVersion(),
      throwsA(isA<ApiProblem>().having((p) => p.status, 'status', 503)),
    );
  });

  test('an invalid version response is rejected', () async {
    for (final broken in [
      {..._version, 'version': '7'},
      {..._version, 'sha256': 'abc'},
      {..._version, 'built_at': 'yesterday'},
      {..._version}..remove('size'),
    ]) {
      final adapter = FakeHttpAdapter(
        response: FakeResponse(200, body: broken),
      );
      await expectLater(
        remote(adapter).fetchVersion(),
        throwsFormatException,
        reason: '$broken',
      );
    }
  });

  group('download', () {
    late Directory dir;

    setUp(() async => dir = await Directory.systemTemp.createTemp('remote-'));
    tearDown(() => dir.delete(recursive: true));

    test('fetches the version from the configured API into the file', () async {
      final bytes = utf8.encode('snapshot bytes');
      final downloads = BytesAdapter(
        200,
        bytes,
        contentType: 'application/vnd.sqlite3',
      );
      final target = File('${dir.path}/incoming');

      await remote(FakeHttpAdapter(), downloads: downloads).download(7, target);

      expect(
        downloads.requests.single.uri.toString(),
        'https://api.example.test/api/v1/catalogue/snapshots/7',
      );
      expect(target.readAsBytesSync(), bytes);
    });

    test('a missing version fails with a problem', () async {
      final downloads = BytesAdapter(404, utf8.encode('{}'));

      await expectLater(
        remote(
          FakeHttpAdapter(),
          downloads: downloads,
        ).download(1, File('${dir.path}/incoming')),
        throwsA(
          isA<ApiProblem>().having(
            (p) => p.kind,
            'kind',
            ApiProblemKind.notFound,
          ),
        ),
      );
    });
  });
}
