import '../data/catalogue_database.dart';
import 'catalogue_remote.dart';
import 'catalogue_store.dart';

/// Outcome of a version check against the server.
enum CatalogueSyncResult {
  /// The device already has the server's current snapshot.
  upToDate,

  /// A new snapshot was downloaded and is now the local catalogue.
  updated,

  /// The server could not be reached or has no snapshot yet; the local
  /// catalogue stays as it is.
  unavailable,

  /// The server's snapshot has a schema this app does not understand (the
  /// app needs an update); the local catalogue stays as it is.
  incompatible,

  /// The download or one of its checks failed; the previous catalogue stays.
  failed,
}

/// FLOW-003 on the device: compares the local snapshot with the server's
/// current one and, when it changed, downloads and swaps it in atomically.
class CatalogueSync {
  CatalogueSync({required this._store, required this._remote});

  final CatalogueStore _store;
  final CatalogueRemote _remote;

  Future<CatalogueSyncResult> run() async {
    final local = await _store.ensureInstalled();

    final RemoteCatalogueVersion remote;
    try {
      final current = await _remote.fetchVersion();
      if (current == null) return CatalogueSyncResult.unavailable;
      remote = current;
    } on Exception {
      return CatalogueSyncResult.unavailable;
    }
    if (remote.schemaVersion != CatalogueDatabase.supportedSchemaVersion) {
      return CatalogueSyncResult.incompatible;
    }
    if (isCurrent(local, remote)) return CatalogueSyncResult.upToDate;

    try {
      await _store.installDownload(
        remote,
        (target) => _remote.download(remote.version, target),
      );
      return CatalogueSyncResult.updated;
    } on Exception {
      return CatalogueSyncResult.failed;
    }
  }

  /// Whether [local] is the server's current snapshot. Version and build time
  /// are compared, so a bundled snapshot built elsewhere with the same
  /// version number is still replaced.
  static bool isCurrent(CatalogueInfo local, RemoteCatalogueVersion remote) =>
      local.version == remote.version &&
      local.builtAt.isAtSameMomentAs(remote.builtAt);
}
