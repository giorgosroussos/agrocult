import 'dart:io';

import 'package:agrocult/core/api/api_problem.dart';
import 'package:agrocult/features/catalogue/data/catalogue_database.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_remote.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_store.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_sync.dart';
import 'package:agrocult/features/catalogue/sync/sha256.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalogue_fakes.dart';

void main() {
  late Directory dir;
  late CatalogueStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('catalogue-sync-');
    store = storeIn(dir);
  });
  tearDown(() => dir.delete(recursive: true));

  File current() => File('${dir.path}/${CatalogueStore.fileName}');

  /// Puts [fixture] in place as the current local catalogue.
  Future<void> installed(Fixture fixture) async {
    await storeIn(dir, bundled: fixture.path).ensureInstalled();
    expect(await Sha256.ofFile(current()), fixture.sha256);
  }

  Future<List<String>> plantNames() async {
    final db = CatalogueDatabase.openSync(current());
    try {
      final rows = await (db.select(
        db.plantTranslations,
      )..where((t) => t.lang.equals('el'))).get();
      return rows.map((r) => r.name).toList()..sort();
    } finally {
      await db.close();
    }
  }

  List<String> filesInDir() =>
      dir.listSync().map((e) => e.uri.pathSegments.last).toList()..sort();

  group('bundled snapshot', () {
    test('is installed on first launch without any network request', () async {
      final remote = OfflineRemote();
      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.unavailable);
      expect(await current().exists(), isTrue);
      expect(
        await Sha256.ofFile(current()),
        await Sha256.ofFile(File(bundledAssetPath)),
      );
      expect(filesInDir(), [CatalogueStore.fileName]);
    });

    test(
      'works offline: the local catalogue opens and is searchable',
      () async {
        await installed(snapshotA);
        final result = await CatalogueSync(
          store: store,
          remote: OfflineRemote(),
        ).run();

        expect(result, CatalogueSyncResult.unavailable);
        expect(await plantNames(), ['Ντομάτα', 'Σκόρδο']);
      },
    );

    test(
      'does not replace a usable downloaded catalogue on later starts',
      () async {
        await installed(snapshotB);

        final info = await store.ensureInstalled();

        expect(info.version, snapshotB.version);
        expect(await Sha256.ofFile(current()), snapshotB.sha256);
      },
    );

    test('replaces an unusable local file (e.g. damaged)', () async {
      await current().writeAsString('not a database');

      final info = await store.ensureInstalled();

      expect(info.schemaVersion, 1);
      expect(
        await Sha256.ofFile(current()),
        await Sha256.ofFile(File(bundledAssetPath)),
      );
    });
  });

  group('version check on start', () {
    test('a newer server snapshot is downloaded and swapped in', () async {
      await installed(snapshotA);
      final remote = FakeCatalogueRemote(
        current: snapshotB.remote(),
        serve: snapshotB,
      );

      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.updated);
      expect(remote.downloads, [snapshotB.version]);
      expect(await Sha256.ofFile(current()), snapshotB.sha256);
      // A plant published after the previous snapshot is now on the device.
      expect(await plantNames(), ['Βασιλικός', 'Ντομάτα', 'Σκόρδο']);
      expect(filesInDir(), [CatalogueStore.fileName]);
    });

    test('the same snapshot is not downloaded again', () async {
      await installed(snapshotB);
      final remote = FakeCatalogueRemote(current: snapshotB.remote());

      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.upToDate);
      expect(remote.versionRequests, 1);
      expect(remote.downloads, isEmpty);
    });

    test('a same-numbered snapshot built at another time is replaced', () {
      final local = CatalogueInfo(
        version: 3,
        schemaVersion: 1,
        builtAt: DateTime.utc(2026, 1, 1),
      );
      expect(CatalogueSync.isCurrent(local, snapshotB.remote()), isFalse);
      expect(
        CatalogueSync.isCurrent(
          CatalogueInfo(
            version: 3,
            schemaVersion: 1,
            builtAt: DateTime.parse(snapshotB.builtAt),
          ),
          snapshotB.remote(),
        ),
        isTrue,
      );
    });

    test('no snapshot on the server keeps the local catalogue', () async {
      await installed(snapshotA);
      final remote = FakeCatalogueRemote();

      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.unavailable);
      expect(await Sha256.ofFile(current()), snapshotA.sha256);
    });

    test('a server error keeps the local catalogue', () async {
      await installed(snapshotA);
      final remote = FakeCatalogueRemote()
        ..versionError = const ApiProblem(
          kind: ApiProblemKind.server,
          status: 503,
        );

      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.unavailable);
      expect(remote.downloads, isEmpty);
      expect(await Sha256.ofFile(current()), snapshotA.sha256);
    });

    test(
      'a snapshot with an unknown schema version is not downloaded',
      () async {
        await installed(snapshotA);
        final remote = FakeCatalogueRemote(
          current: snapshotB.remote(schemaVersion: 2),
          serve: snapshotB,
        );

        final result = await CatalogueSync(store: store, remote: remote).run();

        expect(result, CatalogueSyncResult.incompatible);
        expect(remote.downloads, isEmpty);
        expect(await Sha256.ofFile(current()), snapshotA.sha256);
      },
    );
  });

  group('a failed download keeps the previous catalogue', () {
    Future<void> expectKeptAfter(FakeCatalogueRemote remote) async {
      await installed(snapshotA);

      final result = await CatalogueSync(store: store, remote: remote).run();

      expect(result, CatalogueSyncResult.failed);
      expect(await Sha256.ofFile(current()), snapshotA.sha256);
      expect(await plantNames(), ['Ντομάτα', 'Σκόρδο']);
      expect(filesInDir(), [CatalogueStore.fileName], reason: 'no leftovers');
    }

    test('connection lost mid-download', () async {
      await expectKeptAfter(
        FakeCatalogueRemote(current: snapshotB.remote(), serve: snapshotB)
          ..downloadError = const SocketException('connection reset'),
      );
    });

    test('checksum does not match', () async {
      await expectKeptAfter(
        FakeCatalogueRemote(
          current: snapshotB.remote(sha256: 'f' * 64),
          serve: snapshotB,
        ),
      );
    });

    test('size does not match (truncated transfer)', () async {
      final bytes = snapshotB.file.readAsBytesSync();
      await expectKeptAfter(
        FakeCatalogueRemote(current: snapshotB.remote(), serve: snapshotB)
          ..downloadBytes = bytes.sublist(0, bytes.length - 4096),
      );
    });

    test('the file is not a catalogue snapshot', () async {
      final junk = List.filled(4096, 7);
      final remote = FakeCatalogueRemote(
        current: RemoteCatalogueVersion(
          version: 9,
          schemaVersion: 1,
          builtAt: DateTime.utc(2026, 10, 14),
          size: junk.length,
          sha256: Sha256.ofBytes(junk),
        ),
        serve: snapshotB,
      )..downloadBytes = junk;
      await expectKeptAfter(remote);
    });

    test('the file holds another version than announced', () async {
      // Valid snapshot A served while version 3 (B) was announced.
      final a = snapshotA.remote();
      await expectKeptAfter(
        FakeCatalogueRemote(
          current: RemoteCatalogueVersion(
            version: snapshotB.version,
            schemaVersion: 1,
            builtAt: a.builtAt,
            size: a.size,
            sha256: a.sha256,
          ),
          serve: snapshotA,
        ),
      );
    });
  });
}
