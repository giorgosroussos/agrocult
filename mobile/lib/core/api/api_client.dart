import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'api_problem.dart';

/// Client for the backend REST API under `/api/v1`.
///
/// Attaches the device token from [TokenStorage] as a bearer token, clears it
/// when the server answers 401, and turns every failure into an [ApiProblem].
class ApiClient {
  ApiClient({
    required AppConfig config,
    required this._tokenStorage,
    HttpClientAdapter? httpClientAdapter,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: config.apiV1Url.toString(),
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 20),
           sendTimeout: const Duration(seconds: 20),
           headers: {Headers.acceptHeader: 'application/json'},
           responseType: ResponseType.json,
         ),
       ) {
    if (httpClientAdapter != null) {
      _dio.httpClientAdapter = httpClientAdapter;
    }
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clear();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Paths are relative to `/api/v1/` (e.g. `auth/sign-in`).
  Future<Response<Object?>> get(String path, {Map<String, Object?>? query}) =>
      _send(() => _dio.get<Object?>(_relative(path), queryParameters: query));

  Future<Response<Object?>> post(String path, {Object? data}) =>
      _send(() => _dio.post<Object?>(_relative(path), data: data));

  Future<Response<Object?>> put(String path, {Object? data}) =>
      _send(() => _dio.put<Object?>(_relative(path), data: data));

  Future<Response<Object?>> patch(String path, {Object? data}) =>
      _send(() => _dio.patch<Object?>(_relative(path), data: data));

  Future<Response<Object?>> delete(String path, {Object? data}) =>
      _send(() => _dio.delete<Object?>(_relative(path), data: data));

  /// Rejects absolute URLs so that requests (and the bearer token) never
  /// leave the configured API.
  static String _relative(String path) {
    final uri = Uri.parse(path);
    if (uri.hasScheme || uri.hasAuthority || path.startsWith('//')) {
      throw ArgumentError.value(path, 'path', 'must be relative to /api/v1/');
    }
    return path.startsWith('/') ? path.substring(1) : path;
  }

  static Future<Response<Object?>> _send(
    Future<Response<Object?>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      final response = e.response;
      throw ApiProblem.fromResponse(response?.statusCode, response?.data);
    }
  }
}
