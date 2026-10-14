import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stable id of this app installation; the server keeps one API token per
/// device id (SEC-001).
abstract interface class DeviceIdStorage {
  /// Returns the stored id, creating and storing one on first use.
  Future<String> read();
}

/// [DeviceIdStorage] backed by the platform keystore/keychain.
class SecureDeviceIdStorage implements DeviceIdStorage {
  SecureDeviceIdStorage([FlutterSecureStorage? storage, Random? random])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          ),
      _random = random ?? Random.secure();

  static const _key = 'device_id';

  final FlutterSecureStorage _storage;
  final Random _random;

  @override
  Future<String> read() async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = _generate();
    await _storage.write(key: _key, value: created);
    return created;
  }

  /// 128 random bits as 32 lower-case hex characters.
  String _generate() => List.generate(
    16,
    (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
