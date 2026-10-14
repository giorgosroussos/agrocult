import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'catalogue_database.g.dart';

/// The local catalogue: a catalogue snapshot file built by the backend,
/// opened read-only through drift (schema in `catalogue.drift`).
///
/// The app never creates or changes the tables; a new catalogue arrives as a
/// whole new snapshot file (see `CatalogueStore`).
@DriftDatabase(include: {'catalogue.drift'})
class CatalogueDatabase extends _$CatalogueDatabase {
  CatalogueDatabase(super.executor);

  /// Opens a snapshot file read-only on a background isolate.
  factory CatalogueDatabase.open(File file) => CatalogueDatabase(
    NativeDatabase.createInBackground(file, setup: _readOnly),
  );

  /// Opens a snapshot file read-only on the calling isolate (validation and
  /// tests).
  factory CatalogueDatabase.openSync(File file) {
    // Checking a new snapshot while the current one is open is intended.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return CatalogueDatabase(NativeDatabase(file, setup: _readOnly));
  }

  /// The snapshot schema version this app understands (PRAGMA user_version
  /// and meta.schema_version of the snapshot).
  static const supportedSchemaVersion = 1;

  @override
  int get schemaVersion => supportedSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // A snapshot always carries its schema version; an empty or foreign file
    // is not a catalogue and is never turned into one here.
    onCreate: (m) async =>
        throw const CatalogueSnapshotException('not a catalogue snapshot'),
    onUpgrade: (m, from, to) async => throw CatalogueSnapshotException(
      'unsupported catalogue schema version $from',
    ),
  );

  /// Version information of this snapshot (from its `meta` table).
  Future<CatalogueInfo> info() async {
    final rows = await select(meta).get();
    final values = {for (final row in rows) row.key: row.value};
    final version = int.tryParse(values['version'] ?? '');
    final schema = int.tryParse(values['schema_version'] ?? '');
    final builtAt = DateTime.tryParse(values['built_at'] ?? '');
    if (version == null || schema == null || builtAt == null) {
      throw const CatalogueSnapshotException('snapshot metadata is missing');
    }
    return CatalogueInfo(
      version: version,
      schemaVersion: schema,
      builtAt: builtAt.toUtc(),
    );
  }

  static void _readOnly(dynamic database) {
    // The snapshot file must stay byte-identical to what the server built.
    // ignore: avoid_dynamic_calls
    database.execute('PRAGMA query_only = ON');
  }
}

/// Version of a catalogue snapshot.
class CatalogueInfo {
  const CatalogueInfo({
    required this.version,
    required this.schemaVersion,
    required this.builtAt,
  });

  final int version;
  final int schemaVersion;
  final DateTime builtAt;

  @override
  bool operator ==(Object other) =>
      other is CatalogueInfo &&
      other.version == version &&
      other.schemaVersion == schemaVersion &&
      other.builtAt == builtAt;

  @override
  int get hashCode => Object.hash(version, schemaVersion, builtAt);

  @override
  String toString() =>
      'CatalogueInfo(v$version, schema $schemaVersion, built $builtAt)';
}

/// A file is not a usable catalogue snapshot.
class CatalogueSnapshotException implements Exception {
  const CatalogueSnapshotException(this.message);

  final String message;

  @override
  String toString() => 'CatalogueSnapshotException: $message';
}
