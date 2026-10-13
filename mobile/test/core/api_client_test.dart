import 'dart:io';

import 'package:agrocult/core/api/api_client.dart';
import 'package:agrocult/core/api/api_problem.dart';
import 'package:agrocult/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  late FakeHttpAdapter adapter;
  late InMemoryTokenStorage tokens;
  late ApiClient client;

  setUp(() {
    adapter = FakeHttpAdapter();
    tokens = InMemoryTokenStorage();
    client = ApiClient(
      config: AppConfig.fromValues(
        apiBaseUrl: 'https://api.example.test',
        mapTileUrl: 'https://tiles.example.test',
      ),
      tokenStorage: tokens,
      httpClientAdapter: adapter,
    );
  });

  test('sends requests under the configured /api/v1 base as JSON', () async {
    adapter.response = const FakeResponse(200, body: {'ok': true});

    final response = await client.get('/me', query: {'page': 2});

    final request = adapter.requests.single;
    expect(request.uri.toString(), 'https://api.example.test/api/v1/me?page=2');
    expect(request.headers['Accept'], 'application/json');
    expect(response.data, {'ok': true});
  });

  test('attaches the stored device token as a bearer token', () async {
    tokens.token = 'device-token-1';

    await client.post('auth/sign-out');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer device-token-1',
    );
  });

  test('sends no Authorization header when no token is stored', () async {
    await client.get('catalogue');

    expect(
      adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });

  test('clears the stored token when the server answers 401', () async {
    tokens.token = 'expired';
    adapter.response = const FakeResponse(
      401,
      body: {'title': 'Unauthenticated', 'status': 401},
      contentType: 'application/problem+json',
    );

    await expectLater(
      client.get('gardens'),
      throwsA(
        isA<ApiProblem>().having(
          (p) => p.kind,
          'kind',
          ApiProblemKind.unauthenticated,
        ),
      ),
    );
    expect(tokens.token, isNull);
  });

  test('keeps the token on other errors', () async {
    tokens.token = 'valid';
    adapter.response = const FakeResponse(403, body: {'title': 'Forbidden'});

    await expectLater(client.get('gardens'), throwsA(isA<ApiProblem>()));
    expect(tokens.token, 'valid');
  });

  test('parses RFC 9457 problem details with validation errors', () async {
    adapter.response = const FakeResponse(
      422,
      contentType: 'application/problem+json',
      body: {
        'type': 'https://api.example.test/problems/validation',
        'title': 'The given data was invalid.',
        'status': 422,
        'detail': 'One field is invalid.',
        'errors': {
          'email': ['The email field is required.'],
        },
      },
    );

    final problem = await client
        .post('auth/sign-up', data: {'email': ''})
        .then<ApiProblem?>((_) => null, onError: (Object e) => e as ApiProblem);

    expect(problem, isNotNull);
    expect(problem!.kind, ApiProblemKind.validation);
    expect(problem.status, 422);
    expect(problem.type, 'https://api.example.test/problems/validation');
    expect(problem.title, 'The given data was invalid.');
    expect(problem.detail, 'One field is invalid.');
    expect(problem.errors, {
      'email': ['The email field is required.'],
    });
  });

  test('maps status codes to problem kinds', () async {
    const expected = {
      404: ApiProblemKind.notFound,
      429: ApiProblemKind.rateLimited,
      500: ApiProblemKind.server,
      409: ApiProblemKind.other,
    };
    for (final entry in expected.entries) {
      adapter.response = FakeResponse(entry.key, body: const {});
      await expectLater(
        client.delete('x'),
        throwsA(isA<ApiProblem>().having((p) => p.kind, 'kind', entry.value)),
        reason: '${entry.key}',
      );
    }
  });

  test('turns a non-JSON error body into a problem without details', () async {
    adapter.response = const FakeResponse(502, contentType: 'text/html');

    await expectLater(
      client.put('x', data: const {}),
      throwsA(
        isA<ApiProblem>()
            .having((p) => p.kind, 'kind', ApiProblemKind.server)
            .having((p) => p.title, 'title', isNull),
      ),
    );
  });

  test('reports a network failure as a network problem', () async {
    adapter.error = const SocketException('unreachable');

    await expectLater(
      client.patch('me', data: const {}),
      throwsA(
        isA<ApiProblem>()
            .having((p) => p.kind, 'kind', ApiProblemKind.network)
            .having((p) => p.status, 'status', isNull),
      ),
    );
  });

  test('refuses absolute URLs so the token never leaves the API', () async {
    tokens.token = 'secret';

    for (final path in [
      'https://evil.example.test/steal',
      '//evil.example.test/steal',
    ]) {
      expect(() => client.get(path), throwsArgumentError, reason: path);
    }
    expect(adapter.requests, isEmpty);
  });

  test('problem string form carries no request data', () {
    final problem = ApiProblem.fromResponse(422, {
      'detail': 'user@example.test is invalid',
    });

    expect(problem.toString(), isNot(contains('user@example.test')));
  });
}
