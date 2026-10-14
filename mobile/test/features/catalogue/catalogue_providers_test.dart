import 'dart:io';

import 'package:agrocult/features/catalogue/catalogue_providers.dart';
import 'package:agrocult/features/catalogue/catalogue_sync_on_start.dart';
import 'package:agrocult/features/catalogue/data/catalogue_database.dart';
import 'package:agrocult/features/catalogue/sync/catalogue_sync.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalogue_fakes.dart';

Future<Set<String>> _plants(CatalogueDatabase db) async =>
    (await db.select(db.plants).get()).map((p) => p.scientificName).toSet();

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('catalogue-'));
  tearDown(() => dir.delete(recursive: true));

  ProviderContainer containerWith(FakeCatalogueRemote remote) {
    final container = ProviderContainer(
      overrides: [
        catalogueStoreProvider.overrideWithValue(
          storeIn(dir, bundled: snapshotA.path),
        ),
        catalogueRemoteProvider.overrideWithValue(remote),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('the local catalogue is available before and without a sync', () async {
    final remote = FakeCatalogueRemote();
    final container = containerWith(remote);

    final db = await container.read(localCatalogueProvider.future);

    expect(await _plants(db), {'Solanum lycopersicum', 'Allium sativum'});
    expect(remote.versionRequests, 0);
  });

  test('after an update the provider serves the new snapshot', () async {
    final remote = FakeCatalogueRemote(
      current: snapshotB.remote(),
      serve: snapshotB,
    );
    final container = containerWith(remote);
    final before = await container.read(localCatalogueProvider.future);

    final result = await container.read(catalogueStartupSyncProvider.future);

    expect(result, CatalogueSyncResult.updated);
    final after = await container.read(localCatalogueProvider.future);
    expect(after, isNot(same(before)));
    expect(await _plants(after), contains('Ocimum basilicum'));
  });

  test('a failed update keeps serving the previous catalogue', () async {
    final remote = FakeCatalogueRemote(
      current: snapshotB.remote(sha256: '0' * 64),
      serve: snapshotB,
    );
    final container = containerWith(remote);
    final before = await container.read(localCatalogueProvider.future);

    final result = await container.read(catalogueStartupSyncProvider.future);

    expect(result, CatalogueSyncResult.failed);
    expect(await container.read(localCatalogueProvider.future), same(before));
    expect(await _plants(before), {'Solanum lycopersicum', 'Allium sativum'});
  });

  testWidgets('the version check runs once when the app starts', (
    tester,
  ) async {
    final remote = FakeCatalogueRemote(
      current: snapshotA.remote(),
      serve: snapshotA,
    );
    final container = containerWith(remote);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CatalogueSyncOnStart(
            child: Text('app', textDirection: TextDirection.ltr),
          ),
        ),
      );
      final result = await container.read(catalogueStartupSyncProvider.future);
      expect(result, CatalogueSyncResult.upToDate);
      await tester.pump();
    });

    expect(find.text('app'), findsOneWidget);
    expect(remote.versionRequests, 1);
    expect(remote.downloads, isEmpty);
  });
}
