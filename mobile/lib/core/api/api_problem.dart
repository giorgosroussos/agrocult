/// An API error, parsed from an RFC 9457 problem details response when the
/// server sent one.
class ApiProblem implements Exception {
  const ApiProblem({
    required this.kind,
    this.status,
    this.type,
    this.title,
    this.detail,
    this.code,
    this.errors = const {},
  });

  /// Builds a problem from a response status and body.
  factory ApiProblem.fromResponse(int? status, Object? body) {
    final kind = _kindFor(status);
    if (body is Map) {
      final errors = <String, List<String>>{};
      final rawErrors = body['errors'];
      if (rawErrors is Map) {
        rawErrors.forEach((key, value) {
          if (value is List) {
            errors['$key'] = value.map((e) => '$e').toList(growable: false);
          } else if (value != null) {
            errors['$key'] = ['$value'];
          }
        });
      }
      return ApiProblem(
        kind: kind,
        status: status,
        type: _string(body['type']),
        title: _string(body['title']),
        detail: _string(body['detail']),
        code: _string(body['code']),
        errors: errors,
      );
    }
    return ApiProblem(kind: kind, status: status);
  }

  final ApiProblemKind kind;
  final int? status;
  final String? type;
  final String? title;
  final String? detail;

  /// Machine-readable extension member `code` (e.g. `email_not_verified`).
  final String? code;

  /// Field validation errors (`errors` member), keyed by field name.
  final Map<String, List<String>> errors;

  static String? _string(Object? value) => value is String ? value : null;

  static ApiProblemKind _kindFor(int? status) {
    if (status == null) return ApiProblemKind.network;
    if (status == 401) return ApiProblemKind.unauthenticated;
    if (status == 403) return ApiProblemKind.forbidden;
    if (status == 404) return ApiProblemKind.notFound;
    if (status == 422) return ApiProblemKind.validation;
    if (status == 429) return ApiProblemKind.rateLimited;
    if (status >= 500) return ApiProblemKind.server;
    return ApiProblemKind.other;
  }

  // Deliberately no request data in the string form: it may end up in logs.
  @override
  String toString() => 'ApiProblem(${kind.name}, status: $status)';
}

enum ApiProblemKind {
  network,
  unauthenticated,
  forbidden,
  notFound,
  validation,
  rateLimited,
  server,
  other,
}
