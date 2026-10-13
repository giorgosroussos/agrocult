import 'dart:convert';
import 'dart:typed_data';

import 'package:agrocult/core/auth/token_storage.dart';
import 'package:dio/dio.dart';

class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}

class FakeResponse {
  const FakeResponse(
    this.status, {
    this.body,
    this.contentType = 'application/json',
  });

  final int status;
  final Object? body;
  final String contentType;
}

/// Records requests and answers them with queued responses; never touches
/// the network.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter({this.response = const FakeResponse(200, body: {})});

  FakeResponse response;
  Object? error;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final error = this.error;
    if (error != null) throw error;
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [response.contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
