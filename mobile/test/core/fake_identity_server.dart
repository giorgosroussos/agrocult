import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:agrocult/core/api/api_client.dart';
import 'package:agrocult/core/auth/device_id.dart';
import 'package:agrocult/core/config/app_config.dart';
import 'package:dio/dio.dart';

import 'fakes.dart';

class FakeAccount {
  FakeAccount(this.password, {this.verified = false});

  String password;
  bool verified;
}

/// In-memory stand-in for the `/api/v1/auth` endpoints of CMP-Identity,
/// with the same observable behaviour: answers never reveal whether an
/// email is registered, reset tokens work once, a reset revokes all tokens.
/// Never touches the network.
class FakeIdentityServer implements HttpClientAdapter {
  final Map<String, FakeAccount> accounts = {};

  /// Device id -> issued API token.
  final Map<String, String> tokens = {};

  /// Reset token -> email; a token is removed once used.
  final Map<String, String> resetTokens = {};

  /// Every reset token ever issued, in order (the "sent emails").
  final List<String> sentResetTokens = [];

  final List<RequestOptions> requests = [];

  bool offline = false;
  bool rateLimited = false;
  var _counter = 0;

  void addAccount(String email, String password, {bool verified = true}) =>
      accounts[email] = FakeAccount(password, verified: verified);

  List<RequestOptions> requestsTo(String path) =>
      requests.where((r) => r.uri.path == '/api/v1/$path').toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (offline) throw const SocketException('offline');
    if (rateLimited) {
      return _json(429, {'title': 'Too Many Attempts.', 'status': 429});
    }
    final data = options.data is Map
        ? Map<String, Object?>.from(options.data as Map)
        : <String, Object?>{};
    final email = '${data['email'] ?? ''}'.trim().toLowerCase();
    final path = options.uri.path.replaceFirst('/api/v1/', '');

    switch (path) {
      case 'auth/sign-up':
        if (data['age_confirmed'] != true) {
          return _validation({'age_confirmed': 'must be accepted'});
        }
        accounts.putIfAbsent(email, () => FakeAccount('${data['password']}'));
        return _json(202, {
          'message':
              'If this email address can be used, a confirmation link has '
              'been sent to it.',
        });
      case 'auth/email/verification-notification':
        return _json(202, {'message': 'If this email address needs ...'});
      case 'auth/sign-in':
        final account = accounts[email];
        if (account == null || account.password != data['password']) {
          return _validation({
            'email': 'These credentials do not match our records.',
          });
        }
        if (!account.verified) {
          return _json(403, {
            'title': 'Forbidden',
            'status': 403,
            'detail': 'Confirm your email address before signing in.',
            'code': 'email_not_verified',
          });
        }
        final token = 'token-${++_counter}';
        tokens['${data['device_id']}'] = token;
        return _json(200, {'token': token, 'token_type': 'Bearer'});
      case 'auth/sign-out':
        tokens.removeWhere(
          (_, token) => options.headers['Authorization'] == 'Bearer $token',
        );
        return _json(204, null);
      case 'auth/password/forgot':
        if (accounts.containsKey(email)) {
          final token = 'reset-${++_counter}';
          resetTokens[token] = email;
          sentResetTokens.add(token);
        }
        return _json(202, {
          'message':
              'If an account exists for this email address, a reset link '
              'has been sent to it.',
        });
      case 'auth/password/reset':
        final password = '${data['password'] ?? ''}';
        if (password.length < 8) {
          return _validation({'password': 'too short'});
        }
        final token = '${data['token']}';
        if (resetTokens[token] != email || !accounts.containsKey(email)) {
          return _validation({'token': 'not valid or already used'});
        }
        resetTokens.remove(token);
        accounts[email]!.password = password;
        tokens.clear();
        return _json(200, {'message': 'Your password has been changed.'});
    }
    return _json(404, {'title': 'Not Found', 'status': 404});
  }

  static ResponseBody _validation(Map<String, String> errors) => _json(422, {
    'title': 'The given data was invalid.',
    'status': 422,
    'errors': {
      for (final e in errors.entries) e.key: [e.value],
    },
  });

  static ResponseBody _json(int status, Object? body) =>
      ResponseBody.fromString(
        body == null ? '' : jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [
            status >= 400 ? 'application/problem+json' : 'application/json',
          ],
        },
      );

  @override
  void close({bool force = false}) {}
}

class FixedDeviceIdStorage implements DeviceIdStorage {
  const FixedDeviceIdStorage([this.id = 'device-1']);

  final String id;

  @override
  Future<String> read() async => id;
}

ApiClient fakeApiClient(
  FakeIdentityServer server,
  InMemoryTokenStorage tokens,
) => ApiClient(
  config: AppConfig.fromValues(
    apiBaseUrl: 'https://api.example.test',
    mapTileUrl: 'https://tiles.example.test',
  ),
  tokenStorage: tokens,
  httpClientAdapter: server,
);
