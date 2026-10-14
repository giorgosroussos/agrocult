import 'dart:io';

import 'package:agrocult/features/catalogue/catalogue_providers.dart';
import 'package:agrocult/features/catalogue/data/catalogue_database.dart';

/// Snapshot for the search and plant card tests, written by the backend's
/// SnapshotWriter with search keys from its SearchKeys
/// (`php mobile/test/fixtures/catalogue/build_search_fixture.php`):
/// - Ντομάτα/Tomato: every field and section, calendars in both zones,
///   companions (good: basil, bad: garlic), care intervals, a tip, a source
/// - Σκόρδο/Garlic: sown outdoors Oct-Jan (coastal), Feb-Mar (mountain)
/// - Βασιλικός/Basil (herbs): sown outdoors Apr-Jun (coastal)
/// - Δυόσμος/Spearmint (herbs) with the Greek alias Ηδύοσμος
/// - Ρίγανη (herbs): Greek text only
/// - Μαρούλι/Lettuce (leafy greens, a subcategory of vegetables)
const searchFixturePath = 'test/fixtures/catalogue/search_fixture.sqlite';

String _id(int n) => '00000000-0000-7000-8000-${n.toString().padLeft(12, '0')}';

final vegetablesId = _id(1);
final herbsId = _id(2);
final coastalZoneId = _id(11);
final mountainZoneId = _id(12);
final tomatoId = _id(101);
final garlicId = _id(102);
final basilId = _id(103);
final mintId = _id(104);
final oreganoId = _id(105);
final lettuceId = _id(106);

/// Opens a copy of a fixture snapshot on the calling isolate (usable inside
/// widget tests' fake async zone).
CatalogueDatabase openFixtureCopy(String path) {
  final dir = Directory.systemTemp.createTempSync('catalogue-search-');
  final copy = File(path).copySync('${dir.path}/catalogue.sqlite');
  final db = CatalogueDatabase.openSync(copy);
  return db;
}

/// The local catalogue on a fixed snapshot, without the store.
class FixedLocalCatalogue extends LocalCatalogue {
  FixedLocalCatalogue(this.db);

  final CatalogueDatabase db;

  @override
  Future<CatalogueDatabase> build() async => db;
}
