import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database_location.dart';
import '../../core/providers.dart';
import 'data/catalogue_database.dart';
import 'data/catalogue_models.dart';
import 'data/catalogue_repository.dart';
import 'sync/catalogue_remote.dart';
import 'sync/catalogue_store.dart';
import 'sync/catalogue_sync.dart';

/// The catalogue file on the device, next to the app database.
final catalogueStoreProvider = Provider<CatalogueStore>(
  (ref) => CatalogueStore(
    directory: const DatabaseLocation().directory,
    bundledSnapshot: () => rootBundle.load(CatalogueStore.bundledAsset),
  ),
);

/// The backend's catalogue sync API (public, no account).
final catalogueRemoteProvider = Provider<CatalogueRemote>(
  (ref) => HttpCatalogueRemote(
    api: ref.watch(apiClientProvider),
    config: ref.watch(appConfigProvider),
  ),
);

final catalogueSyncProvider = Provider<CatalogueSync>(
  (ref) => CatalogueSync(
    store: ref.watch(catalogueStoreProvider),
    remote: ref.watch(catalogueRemoteProvider),
  ),
);

/// The local catalogue database. Available offline from the first launch
/// (bundled snapshot); replaced by a newer snapshot after a sync.
final localCatalogueProvider =
    AsyncNotifierProvider<LocalCatalogue, CatalogueDatabase>(
      LocalCatalogue.new,
    );

/// Runs the catalogue version check once per app start.
final catalogueStartupSyncProvider = FutureProvider<CatalogueSyncResult>(
  (ref) => ref.read(localCatalogueProvider.notifier).sync(),
  // One check per start; the next start checks again.
  retry: (_, _) => null,
);

class LocalCatalogue extends AsyncNotifier<CatalogueDatabase> {
  CatalogueDatabase? _open;

  @override
  Future<CatalogueDatabase> build() async {
    ref.onDispose(() {
      final db = _open;
      _open = null;
      if (db != null) unawaited(db.close());
    });
    final store = ref.watch(catalogueStoreProvider);
    await store.ensureInstalled();
    return _open = CatalogueDatabase.open(await store.currentFile());
  }

  /// Checks the server for a newer snapshot; when one was installed, the
  /// catalogue is reopened on it and the previous connection closed.
  Future<CatalogueSyncResult> sync() async {
    final previous = await future;
    final result = await ref.read(catalogueSyncProvider).run();
    if (result == CatalogueSyncResult.updated && ref.mounted) {
      final store = ref.read(catalogueStoreProvider);
      final next = CatalogueDatabase.open(await store.currentFile());
      _open = next;
      state = AsyncData(next);
      await previous.close();
    }
    return result;
  }
}

/// Search and plant cards over the local catalogue (UC-003, UC-004).
final catalogueRepositoryProvider = FutureProvider<CatalogueRepository>(
  (ref) async =>
      CatalogueRepository(await ref.watch(localCatalogueProvider.future)),
);

/// Climate zones of the user's gardens, for 'in season now' (SCOPE-003: the
/// garden's location, never the device's position). Empty for a visitor or
/// a gardener without a garden: then a plant is in season when it is in
/// season in any zone. The gardens feature provides the real value by
/// overriding this provider where the app is composed.
final seasonClimateZonesProvider = Provider<Set<String>>((ref) => const {});

/// Today's date for 'in season now' (replaced in tests).
final catalogueTodayProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Categories named in a UI language.
final catalogueCategoriesProvider = FutureProvider.autoDispose
    .family<List<CategoryItem>, String>(
      (ref, lang) async => (await ref.watch(
        catalogueRepositoryProvider.future,
      )).categories(lang),
    );

/// Search results for a query.
final plantSearchProvider = FutureProvider.autoDispose
    .family<List<PlantListItem>, PlantQuery>(
      (ref, query) async =>
          (await ref.watch(catalogueRepositoryProvider.future)).search(query),
    );

/// Which plant card to show, in which language, with which zone first.
typedef PlantCardRequest = ({String plantId, String lang, String? zoneId});

/// The plant card; null when the plant is not in the local catalogue.
final plantCardProvider = FutureProvider.autoDispose
    .family<PlantCardData?, PlantCardRequest>(
      (ref, request) async =>
          (await ref.watch(catalogueRepositoryProvider.future)).plantCard(
            request.plantId,
            lang: request.lang,
            preferredZoneId: request.zoneId,
          ),
    );
