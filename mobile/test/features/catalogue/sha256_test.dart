import 'dart:convert';

import 'package:agrocult/features/catalogue/sync/sha256.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalogue_fakes.dart';

void main() {
  test('matches the FIPS 180-4 test vectors', () {
    expect(
      Sha256.ofBytes([]),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      Sha256.ofBytes(utf8.encode('abc')),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(
      Sha256.ofBytes(
        utf8.encode('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
      ),
      '248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1',
    );
    expect(
      Sha256.ofBytes(List.filled(1000000, 0x61)),
      'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0',
    );
  });

  test('chunked input gives the same digest', () {
    final hash = Sha256()
      ..add(utf8.encode('ab'))
      ..add(utf8.encode('c'));
    expect(
      hash.hexDigest(),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    expect(() => hash.add([1]), throwsStateError);
  });

  test(
    'agrees with the checksum the backend announced for a snapshot',
    () async {
      expect(await Sha256.ofFile(snapshotA.file), snapshotA.sha256);
      expect(await Sha256.ofFile(snapshotB.file), snapshotB.sha256);
    },
  );
}
