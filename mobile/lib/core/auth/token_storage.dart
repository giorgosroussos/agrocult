import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the API token of this device (one token per device, SEC-001).
abstract interface class TokenStorage {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// [TokenStorage] backed by the platform keystore/keychain.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _key = 'api_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    final value = await _storage.read(key: _key);
    return (value == null || value.isEmpty) ? null : value;
  }

  @override
  Future<void> write(String token) {
    if (token.isEmpty) {
      throw ArgumentError.value(token, 'token', 'must not be empty');
    }
    return _storage.write(key: _key, value: token);
  }

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
