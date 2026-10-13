import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'database_location.dart';

part 'app_database.g.dart';

/// Local SQLite database of the app (drift).
///
/// Feature tables (e.g. the catalogue with FTS5 search) are added by the
/// features that own them; this class only sets the database up.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the database file in the app's private storage.
  factory AppDatabase.open({DatabaseLocation? location}) {
    final where = location ?? const DatabaseLocation();
    return AppDatabase(
      LazyDatabase(() async {
        final directory = await where.directory();
        final file = File('$directory${Platform.pathSeparator}$fileName');
        return NativeDatabase.createInBackground(file);
      }),
    );
  }

  static const fileName = 'agrocult.sqlite';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
