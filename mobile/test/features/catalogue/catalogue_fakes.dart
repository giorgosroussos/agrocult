import 'dart:io';
import 'dart:typed_data';

import 'package:agrocult/features/catalogue/sync/catalogue_remote.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_store.dart';

/// Snapshots built by the backend (`CatalogueSnapshots::rebuild()`, schema
/// version 1) for these tests:
/// - A (version 2): published Ντομάτα and Σκόρδο; draft Δυόσμος left out.
/// - B (version 3): A plus the newly published Βασιλικός.
class Fixture {
  const Fixture(this.path, this.version, this.sha256, this.builtAt);

  final String path;
  final int version;
  final String sha256;
  final String builtAt;

  File get file => File(path);

  RemoteCatalogueVersion remote({int? schemaVersion, String? sha256}) =>
      RemoteCatalogueVersion(
        version: version,
        schemaVersion: schemaVersion ?? 1,
        builtAt: DateTime.parse(builtAt),
        size: file.lengthSync(),
        sha256: sha256 ?? this.sha256,
      );
}

const snapshotA = Fixture(
  'test/fixtures/catalogue/snapshot_a.sqlite',
  2,
  'bf757a539f4cb314ccec67e64c4d3b6a69c9f6936e974acb588d1675a31132df',
  '2026-10-14T12:39:39Z',
);

const snapshotB = Fixture(
  'test/fixtures/catalogue/snapshot_b.sqlite',
  3,
  'aa8b2d14a0a4d9035a40dc4a89b92d308131e20556487c4ed961060a11b31edc',
  '2026-10-14T12:39:39Z',
);

/// The snapshot bundled with the app.
const bundledAssetPath = 'assets/catalogue/catalogue.sqlite';

/// A store in a fresh temporary directory whose bundled snapshot is [bundled].
CatalogueStore storeIn(Directory dir, {String bundled = bundledAssetPath}) =>
    CatalogueStore(
      directory: () async => dir.path,
      bundledSnapshot: () async =>
          ByteData.sublistView(File(bundled).readAsBytesSync()),
    );

/// Serves fixture snapshots; never touches the network.
class FakeCatalogueRemote implements CatalogueRemote {
  FakeCatalogueRemote({this.current, this.serve});

  /// What `fetchVersion` returns; null means no snapshot on the server.
  RemoteCatalogueVersion? current;

  /// File handed out by `download`.
  Fixture? serve;

  /// Thrown by `fetchVersion` (e.g. no network).
  Exception? versionError;

  /// Thrown by `download` after a partial write.
  Exception? downloadError;

  /// Replaces the downloaded bytes (e.g. a corrupted transfer).
  List<int>? downloadBytes;

  int versionRequests = 0;
  final List<int> downloads = [];

  @override
  Future<RemoteCatalogueVersion?> fetchVersion() async {
    versionRequests++;
    final error = versionError;
    if (error != null) throw error;
    return current;
  }

  @override
  Future<void> download(int version, File target) async {
    downloads.add(version);
    final bytes = downloadBytes ?? serve!.file.readAsBytesSync();
    final error = downloadError;
    if (error != null) {
      target.writeAsBytesSync(bytes.sublist(0, bytes.length ~/ 2));
      throw error;
    }
    target.writeAsBytesSync(bytes);
  }
}

/// Fails the test when any network call is attempted.
class OfflineRemote implements CatalogueRemote {
  int calls = 0;

  @override
  Future<RemoteCatalogueVersion?> fetchVersion() async {
    calls++;
    throw const SocketException('offline');
  }

  @override
  Future<void> download(int version, File target) async {
    calls++;
    throw const SocketException('offline');
  }
}
