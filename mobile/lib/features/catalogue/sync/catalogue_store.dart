import 'dart:io';
import 'dart:typed_data';

import '../data/catalogue_database.dart';
import 'catalogue_remote.dart';
import 'sha256.dart';

/// Keeps the local catalogue file on the device (ARCH-003).
///
/// The current catalogue is one snapshot file. A new snapshot (the bundled
/// one on first launch, or a download) is first written next to it, checked,
/// and only then renamed over it in a single atomic step. Anything that fails
/// on the way leaves the current file untouched.
class CatalogueStore {
  CatalogueStore({required this._directory, required this._bundledSnapshot});

  /// Asset path of the snapshot bundled with the app.
  static const bundledAsset = 'assets/catalogue/catalogue.sqlite';

  static const fileName = 'catalogue.sqlite';
  static const _incomingName = 'catalogue.sqlite.incoming';

  final Future<String> Function() _directory;
  final Future<ByteData> Function() _bundledSnapshot;

  /// The file of the current local catalogue.
  Future<File> currentFile() async => _file(fileName);

  /// Makes sure a usable catalogue is on the device: installs the bundled
  /// snapshot when there is none yet or the current one is unusable (e.g.
  /// an older schema after an app update). Works without network.
  Future<CatalogueInfo> ensureInstalled() async {
    final current = await currentFile();
    if (await current.exists()) {
      try {
        return await _inspect(current, deep: false);
      } on Exception {
        // Unusable: replaced by the bundled snapshot below.
      }
    }
    final bytes = await _bundledSnapshot();
    return _install((incoming) async {
      await incoming.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    });
  }

  /// Downloads [remote] with [download] and, when it checks out, makes it the
  /// current catalogue. Throws when the download or a check fails; the
  /// current catalogue then stays as it was.
  Future<CatalogueInfo> installDownload(
    RemoteCatalogueVersion remote,
    Future<void> Function(File target) download,
  ) {
    return _install((incoming) async {
      await download(incoming);
      final size = await incoming.length();
      if (size != remote.size) {
        throw CatalogueSnapshotException(
          'size mismatch: expected ${remote.size}, got $size',
        );
      }
      if (await Sha256.ofFile(incoming) != remote.sha256) {
        throw const CatalogueSnapshotException('checksum mismatch');
      }
    }, expectedVersion: remote.version);
  }

  Future<CatalogueInfo> _install(
    Future<void> Function(File incoming) write, {
    int? expectedVersion,
  }) async {
    final incoming = await _file(_incomingName);
    try {
      await _delete(incoming);
      await write(incoming);
      final info = await _inspect(incoming, deep: true);
      if (expectedVersion != null && info.version != expectedVersion) {
        throw CatalogueSnapshotException(
          'expected version $expectedVersion, got ${info.version}',
        );
      }
      // rename(2) replaces the current file atomically.
      await incoming.rename((await currentFile()).path);
      return info;
    } finally {
      await _delete(incoming);
    }
  }

  /// Opens [file] read-only and checks that it is a catalogue snapshot this
  /// app understands; [deep] also checks the file's integrity and tables.
  Future<CatalogueInfo> _inspect(File file, {required bool deep}) async {
    final db = CatalogueDatabase.openSync(file);
    try {
      final info = await db.info();
      if (info.schemaVersion != CatalogueDatabase.supportedSchemaVersion) {
        throw CatalogueSnapshotException(
          'unsupported schema version ${info.schemaVersion}',
        );
      }
      if (deep) {
        final check = await db.customSelect('PRAGMA quick_check').get();
        if (check.length != 1 || check.single.data.values.single != 'ok') {
          throw const CatalogueSnapshotException('integrity check failed');
        }
        final rows = await db
            .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
            .get();
        final present = {for (final row in rows) row.read<String>('name')};
        final missing = db.allTables
            .map((t) => t.actualTableName)
            .where((name) => !present.contains(name));
        if (missing.isNotEmpty) {
          throw CatalogueSnapshotException('missing tables: $missing');
        }
      }
      return info;
    } on CatalogueSnapshotException {
      rethrow;
    } on Exception catch (e) {
      // e.g. not a database file: its content is not logged or kept.
      throw CatalogueSnapshotException(
        'unreadable snapshot (${e.runtimeType})',
      );
    } finally {
      await db.close();
    }
  }

  Future<File> _file(String name) async {
    final directory = await _directory();
    return File('$directory${Platform.pathSeparator}$name');
  }

  static Future<void> _delete(File file) async {
    if (await file.exists()) await file.delete();
  }
}
