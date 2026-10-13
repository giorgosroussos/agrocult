import 'package:agrocult/core/auth/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('reads nothing before a token is stored', () async {
    expect(await SecureTokenStorage().read(), isNull);
  });

  test('stores, reads and clears the device token in secure storage', () async {
    final storage = SecureTokenStorage();

    await storage.write('device-token');
    expect(await storage.read(), 'device-token');
    expect(
      await const FlutterSecureStorage().read(key: 'api_token'),
      'device-token',
    );

    await storage.clear();
    expect(await storage.read(), isNull);
  });

  test('replaces the previous token (one token per device)', () async {
    final storage = SecureTokenStorage();

    await storage.write('first');
    await storage.write('second');

    expect(await storage.read(), 'second');
  });

  test('rejects an empty token', () async {
    expect(() => SecureTokenStorage().write(''), throwsArgumentError);
    expect(await SecureTokenStorage().read(), isNull);
  });
}
