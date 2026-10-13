import 'package:agrocult/core/db/app_database.dart';
import 'package:agrocult/core/db/database_location.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('opens at schema version 1 with foreign keys enforced', () async {
      expect(db.schemaVersion, 1);
      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(row.read<int>('foreign_keys'), 1);
    });

    test('supports FTS5 for the local catalogue search', () async {
      await db.customStatement('CREATE VIRTUAL TABLE probe USING fts5(name)');
      await db.customStatement("INSERT INTO probe VALUES ('vasilikos')");
      final rows = await db
          .customSelect(
            'SELECT name FROM probe WHERE probe MATCH ?',
            variables: [Variable.withString('vasil*')],
          )
          .get();
      expect(rows.single.read<String>('name'), 'vasilikos');
    });
  });

  group('DatabaseLocation', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(
      () => messenger.setMockMethodCallHandler(DatabaseLocation.channel, null),
    );

    test('asks the host app for the private database directory', () async {
      messenger.setMockMethodCallHandler(DatabaseLocation.channel, (
        call,
      ) async {
        expect(call.method, 'databaseDirectory');
        return '/data/user/0/gr.agrocult.agrocult/databases';
      });

      expect(
        await const DatabaseLocation().directory(),
        '/data/user/0/gr.agrocult.agrocult/databases',
      );
    });

    test('fails when the host app returns no directory', () async {
      messenger.setMockMethodCallHandler(
        DatabaseLocation.channel,
        (call) async => null,
      );

      await expectLater(const DatabaseLocation().directory(), throwsStateError);
    });

    test('fails when the host app does not implement the channel', () async {
      await expectLater(
        const DatabaseLocation().directory(),
        throwsA(isA<MissingPluginException>()),
      );
    });
  });
}
