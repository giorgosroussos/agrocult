import 'package:dio/dio.dart' show Response;

import '../api/api_client.dart';
import '../api/api_problem.dart';
import 'device_id.dart';
import 'token_storage.dart';

/// Why an auth request failed, in terms the screens can show.
enum AuthError {
  /// Wrong email or password; deliberately the same for an unknown email
  /// (DEC-004).
  invalidCredentials,

  /// The account exists but its email address is not confirmed yet.
  emailNotVerified,

  /// The reset link is unknown, expired or already used.
  invalidResetLink,

  /// The server rejected a field (e.g. a password that is too short).
  invalidInput,

  /// Too many attempts; try again later.
  rateLimited,

  /// The server could not be reached.
  network,

  /// Any other server failure.
  server,
}

class AuthException implements Exception {
  const AuthException(this.error, {this.fields = const {}});

  final AuthError error;

  /// Names of the fields the server rejected (no server text: it may
  /// contain user input and is not localised for the app).
  final Set<String> fields;

  @override
  String toString() => 'AuthException(${error.name})';
}

/// Account endpoints of the backend (`/api/v1/auth`, CMP-Identity).
///
/// No answer of the server reveals whether an email address is registered,
/// so sign-up, verification resend and reset requests simply succeed.
class AuthRepository {
  AuthRepository({
    required this._api,
    required this._tokenStorage,
    required this._deviceIdStorage,
  });

  final ApiClient _api;
  final TokenStorage _tokenStorage;
  final DeviceIdStorage _deviceIdStorage;

  /// UC-012 step 1. [ageConfirmed] must be true (SEC-004).
  Future<void> signUp({
    required String email,
    required String password,
    required bool ageConfirmed,
    required String language,
  }) async {
    if (!ageConfirmed) {
      throw const AuthException(
        AuthError.invalidInput,
        fields: {'age_confirmed'},
      );
    }
    await _call(
      () => _api.post(
        'auth/sign-up',
        data: {
          'email': email.trim(),
          'password': password,
          'age_confirmed': true,
          'language': language,
        },
      ),
    );
  }

  /// Sends a new confirmation link (if the address needs one).
  Future<void> resendVerification(String email) => _call(
    () => _api.post(
      'auth/email/verification-notification',
      data: {'email': email.trim()},
    ),
  );

  /// UC-012 step 3: signs in this device and stores its API token.
  Future<void> signIn({required String email, required String password}) async {
    final deviceId = await _deviceIdStorage.read();
    final response = await _call(
      () => _api.post(
        'auth/sign-in',
        data: {
          'email': email.trim(),
          'password': password,
          'device_id': deviceId,
        },
      ),
      onValidation: (_) => AuthError.invalidCredentials,
    );
    final token = response is Map ? response['token'] : null;
    if (token is! String || token.isEmpty) {
      throw const AuthException(AuthError.server);
    }
    await _tokenStorage.write(token);
  }

  /// Revokes this device's token on the server and forgets it locally, even
  /// when the server cannot be reached (the next sign-in on this device
  /// replaces the token anyway).
  Future<void> signOut({String? pushToken}) async {
    try {
      if (await _tokenStorage.read() != null) {
        await _api.post('auth/sign-out', data: {'push_token': ?pushToken});
      }
    } on ApiProblem {
      // Signed out locally regardless.
    } finally {
      await _tokenStorage.clear();
    }
  }

  /// UC-013 step 1.
  Future<void> requestPasswordReset(String email) => _call(
    () => _api.post('auth/password/forgot', data: {'email': email.trim()}),
  );

  /// UC-013 step 2: sets a new password with the one-time link. The server
  /// revokes every token of the account, so this device is signed out too.
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    await _call(
      () => _api.post(
        'auth/password/reset',
        data: {'token': token, 'email': email, 'password': password},
      ),
      onValidation: (fields) => fields.contains('password')
          ? AuthError.invalidInput
          : AuthError.invalidResetLink,
    );
    await _tokenStorage.clear();
  }

  /// Runs [request] and returns the response body.
  static Future<Object?> _call(
    Future<Response<Object?>> Function() request, {
    AuthError Function(Set<String> fields)? onValidation,
  }) async {
    try {
      return (await request()).data;
    } on ApiProblem catch (problem) {
      throw _map(problem, onValidation);
    }
  }

  static AuthException _map(
    ApiProblem problem,
    AuthError Function(Set<String> fields)? onValidation,
  ) {
    final fields = problem.errors.keys.toSet();
    switch (problem.kind) {
      case ApiProblemKind.validation:
        return AuthException(
          onValidation?.call(fields) ?? AuthError.invalidInput,
          fields: fields,
        );
      case ApiProblemKind.forbidden when problem.code == 'email_not_verified':
        return const AuthException(AuthError.emailNotVerified);
      case ApiProblemKind.rateLimited:
        return const AuthException(AuthError.rateLimited);
      case ApiProblemKind.network:
        return const AuthException(AuthError.network);
      default:
        return const AuthException(AuthError.server);
    }
  }
}
