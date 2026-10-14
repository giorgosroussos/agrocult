import 'dart:io';

import 'package:agrocult/features/catalogue/data/catalogue_database.dart';
import 'package:agrocult/features/catalogue/sync/sha256.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalogue_fakes.dart';

const _sqlTypes = {
  'TEXT': DriftSqlType.string,
  'INTEGER': DriftSqlType.int,
  'REAL': DriftSqlType.double,
};

bool _isFtsShadow(String name) =>
    RegExp(r'_(data|idx|content|docsize|config)$').hasMatch(name);

void main() {
  late CatalogueDatabase db;

  setUp(() => db = CatalogueDatabase.openSync(snapshotA.file));
  tearDown(() => db.close());

  group('drift schema matches the snapshot built by the backend', () {
    test('every snapshot table and index is declared, and only those', () async {
      final rows = await db
          .customSelect(
            "SELECT type, name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%'",
          )
          .get();
      final tables = <String>{};
      final indexes = <String>{};
      for (final row in rows) {
        final name = row.read<String>('name');
        if (row.read<String>('type') == 'table' && !_isFtsShadow(name)) {
          tables.add(name);
        } else if (row.read<String>('type') == 'index') {
          indexes.add(name);
        }
      }

      expect(db.allTables.map((t) => t.actualTableName).toSet(), tables);
      expect(
        db.allSchemaEntities
            .whereType<Index>()
            .map((i) => i.entityName)
            .toSet(),
        indexes,
      );
    });

    test(
      'every column has the same name, order, type and nullability',
      () async {
        for (final table in db.allTables) {
          final name = table.actualTableName;
          final info = await db
              .customSelect('PRAGMA table_info("$name")')
              .get();
          final declared = table.$columns;

          expect(
            declared.map((c) => c.name).toList(),
            info.map((r) => r.read<String>('name')).toList(),
            reason: 'columns of $name',
          );
          if (table is VirtualTableInfo) continue;

          for (final row in info) {
            final column = declared.singleWhere(
              (c) => c.name == row.read<String>('name'),
            );
            final notNull = row.read<int>('notnull') == 1;
            expect(
              column.type,
              _sqlTypes[row.read<String>('type')],
              reason: '$name.${column.name} type',
            );
            expect(
              column.$nullable,
              !notNull,
              reason: '$name.${column.name} nullability',
            );
          }
        }
      },
    );

    test(
      'the snapshot carries schema version 1 in user_version and meta',
      () async {
        final pragma = await db.customSelect('PRAGMA user_version').getSingle();
        expect(pragma.read<int>('user_version'), 1);
        expect(CatalogueDatabase.supportedSchemaVersion, 1);
        expect(
          await db.info(),
          CatalogueInfo(
            version: snapshotA.version,
            schemaVersion: 1,
            builtAt: DateTime.parse(snapshotA.builtAt),
          ),
        );
      },
    );
  });

  test('reads the published catalogue through the typed tables', () async {
    final plants = await db.select(db.plants).get();
    expect(plants.map((p) => p.scientificName).toSet(), {
      'Solanum lycopersicum',
      'Allium sativum',
    });

    final names = await db.select(db.plantTranslations).get();
    expect(names.where((t) => t.lang == 'el').map((t) => t.name).toSet(), {
      'Ντομάτα',
      'Σκόρδο',
    });
    // The draft plant never reaches the device.
    expect(names.map((t) => t.name), isNot(contains('Δυόσμος')));
  });

  test('the snapshot FTS5 index answers prefix queries', () async {
    final rows = await db
        .customSelect(
          'SELECT plant_id FROM plant_search WHERE plant_search MATCH ?',
          variables: [Variable.withString('"skor"*')],
        )
        .get();
    final garlic = await (db.select(
      db.plants,
    )..where((p) => p.scientificName.equals('Allium sativum'))).getSingle();
    expect(rows.map((r) => r.read<String>('plant_id')), [garlic.id]);
  });

  test('the file is opened read-only and never changed', () async {
    final before = await Sha256.ofFile(snapshotA.file);

    await expectLater(
      db.customStatement("INSERT INTO meta VALUES ('x', 'y')"),
      throwsA(anything),
    );
    await db.close();

    expect(before, snapshotA.sha256);
    expect(await Sha256.ofFile(snapshotA.file), snapshotA.sha256);
    db = CatalogueDatabase.openSync(snapshotA.file);
  });

  test(
    'a file that is not a snapshot is refused, not turned into one',
    () async {
      final dir = await Directory.systemTemp.createTemp('catalogue-db-');
      addTearDown(() => dir.delete(recursive: true));
      final empty = CatalogueDatabase.openSync(
        File('${dir.path}/empty.sqlite'),
      );
      addTearDown(empty.close);

      await expectLater(empty.info(), throwsA(anything));
    },
  );

  test('the bundled snapshot is a schema 1 catalogue', () async {
    final bundled = CatalogueDatabase.openSync(File(bundledAssetPath));
    addTearDown(bundled.close);

    final info = await bundled.info();
    expect(info.schemaVersion, CatalogueDatabase.supportedSchemaVersion);
    expect(info.version, greaterThanOrEqualTo(1));
  });
}
