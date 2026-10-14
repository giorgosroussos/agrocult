import 'package:agrocult/core/auth/device_id.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('creates a random id once and keeps it', () async {
    final first = await SecureDeviceIdStorage().read();
    final again = await SecureDeviceIdStorage().read();

    expect(first, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(again, first);
    expect(await const FlutterSecureStorage().read(key: 'device_id'), first);
  });

  test('different installations get different ids', () async {
    final a = await SecureDeviceIdStorage().read();
    FlutterSecureStorage.setMockInitialValues({});
    final b = await SecureDeviceIdStorage().read();

    expect(a, isNot(b));
  });
}
