// UC-003 search and UC-004 plant card data, read from the local catalogue
// through the same providers the screens use.
import 'dart:io';

import 'package:agrocult/core/providers.dart';
import 'package:agrocult/features/catalogue/catalogue_providers.dart';
import 'package:agrocult/features/catalogue/data/catalogue_models.dart';
import 'package:agrocult/features/catalogue/data/catalogue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalogue_fakes.dart';
import 'search_fixture.dart';

void main() {
  late Directory dir;
  late OfflineRemote remote;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('catalogue-search-');
    remote = OfflineRemote();
  });
  tearDown(() => dir.delete(recursive: true));

  /// A device whose local catalogue is [bundled], installed on first launch
  /// from the app bundle; every network call fails.
  Future<CatalogueRepository> repositoryOn(String bundled) async {
    final container = ProviderContainer(
      overrides: [
        catalogueStoreProvider.overrideWithValue(
          storeIn(dir, bundled: bundled),
        ),
        catalogueRemoteProvider.overrideWithValue(remote),
        apiClientProvider.overrideWith(
          (ref) => throw StateError('no API client is needed offline'),
        ),
      ],
    );
    addTearDown(() async {
      final db = container.read(localCatalogueProvider).value;
      container.dispose();
      await db?.close();
    });
    return container.read(catalogueRepositoryProvider.future);
  }

  Future<List<String>> names(
    CatalogueRepository repo,
    String text, {
    String lang = 'el',
  }) async => [
    for (final item in await repo.search(PlantQuery(lang: lang, text: text)))
      item.name.text,
  ];

  group('search (UC-003)', () {
    late CatalogueRepository repo;

    setUp(() async => repo = await repositoryOn(searchFixturePath));

    test("Given the catalogue contains 'Ντομάτα', When the user searches "
        "'τοματα', Then 'Ντομάτα' is in the results", () async {
      expect(await names(repo, 'τοματα'), contains('Ντομάτα'));
      expect(await names(repo, 'Τομάτα'), contains('Ντομάτα'));
    });

    test("Given the catalogue contains 'Ντομάτα', When the user searches "
        "'ntomata' or 'domata', Then 'Ντομάτα' is in the results", () async {
      expect(await names(repo, 'ntomata'), contains('Ντομάτα'));
      expect(await names(repo, 'domata'), contains('Ντομάτα'));
      expect(await names(repo, 'DOMATA'), contains('Ντομάτα'));
    });

    test("Given the alias 'ηδύοσμος' for 'Δυόσμος', When the user searches "
        "'ηδυοσμος', Then 'Δυόσμος' is in the results", () async {
      expect(await names(repo, 'ηδυοσμος'), ['Δυόσμος']);
      expect(await names(repo, 'Ηδύοσμος'), ['Δυόσμος']);
    });

    test("Given the UI language is Greek, When the user searches 'basil', "
        "Then 'Βασιλικός' is in the results", () async {
      expect(await names(repo, 'basil'), ['Βασιλικός']);
      // And the other way round.
      expect(await names(repo, 'βασιλικός', lang: 'en'), ['Basil']);
    });

    test("Given the device is offline, When the user searches 'σκόρδο', "
        'Then results appear without any network request', () async {
      expect(await names(repo, 'σκόρδο'), ['Σκόρδο']);
      expect(remote.calls, 0);
    });

    test('a query matches word prefixes, all words required', () async {
      expect(await names(repo, 'ντομ'), ['Ντομάτα']);
      expect(await names(repo, 'solanum lyco'), ['Ντομάτα']);
      expect(await names(repo, 'solanum sativum'), isEmpty);
    });

    test('an unknown name finds nothing', () async {
      expect(await names(repo, 'μπανάνα'), isEmpty);
      expect(await names(repo, '"*()'), hasLength(6), reason: 'no words');
    });

    test('an empty query lists all plants sorted by name', () async {
      expect(await names(repo, ''), [
        'Βασιλικός',
        'Δυόσμος',
        'Μαρούλι',
        'Ντομάτα',
        'Ρίγανη',
        'Σκόρδο',
      ]);
    });

    test('a category filter includes its subcategories', () async {
      Future<List<String>> inCategory(String id) async => [
        for (final item in await repo.search(
          PlantQuery(lang: 'el', categoryId: id),
        ))
          item.name.text,
      ];

      expect(await inCategory(herbsId), ['Βασιλικός', 'Δυόσμος', 'Ρίγανη']);
      expect(await inCategory(vegetablesId), ['Μαρούλι', 'Ντομάτα', 'Σκόρδο']);
    });

    test('categories come from the catalogue in curator order', () async {
      expect(
        [for (final c in await repo.categories('en')) c.name],
        ['Vegetables', 'Herbs', 'Leafy greens'],
      );
      expect(
        [for (final c in await repo.categories('el')) c.name],
        ['Λαχανικά', 'Αρωματικά', 'Φυλλώδη'],
      );
    });
  });

  group("'in season now' (UC-003)", () {
    late CatalogueRepository repo;

    setUp(() async => repo = await repositoryOn(searchFixturePath));

    Future<List<String>> inSeason(int month, Set<String> zones) async => [
      for (final item in await repo.search(
        PlantQuery(
          lang: 'en',
          inSeason: true,
          month: month,
          inSeasonZones: zones,
        ),
      ))
        item.name.text,
    ];

    test('Given a garden in a climate zone where garlic sowing months include '
        "the current month, When the user filters 'in season now', Then "
        'garlic is listed', () async {
      // Coastal garlic is sown October to January.
      expect(await inSeason(11, {coastalZoneId}), ['Garlic']);
      expect(await inSeason(1, {coastalZoneId}), ['Garlic']);
      expect(await inSeason(3, {mountainZoneId}), contains('Garlic'));
    });

    test(
      'garlic is not listed outside its sowing months in the zone',
      () async {
        expect(await inSeason(11, {mountainZoneId}), isEmpty);
        expect(await inSeason(4, {coastalZoneId}), isNot(contains('Garlic')));
      },
    );

    test('harvest and transplant months do not count as in season', () async {
      // Lettuce is only harvested (Nov-Feb); tomato transplanted Apr-May.
      expect(await inSeason(12, {coastalZoneId}), isNot(contains('Lettuce')));
      expect(await inSeason(5, {coastalZoneId}), ['Basil']);
    });

    test('without a garden zone, in season in any zone counts', () async {
      expect(await inSeason(3, {}), ['Garlic', 'Tomato']);
    });

    test('combines with search text and category', () async {
      final items = await repo.search(
        PlantQuery(
          lang: 'en',
          text: 'σκορδο',
          categoryId: herbsId,
          inSeason: true,
          month: 11,
        ),
      );
      expect(items, isEmpty);
    });
  });

  group('plant card (UC-004)', () {
    late CatalogueRepository repo;

    setUp(() async => repo = await repositoryOn(searchFixturePath));

    test('has every section in the UI language', () async {
      final card = (await repo.plantCard(tomatoId, lang: 'en'))!;

      expect(card.name, const LocalText('Tomato', 'en', isFallback: false));
      expect(card.scientificName, 'Solanum lycopersicum');
      expect(card.otherNames, containsAll(['Ντομάτα', 'Ντοματιά']));
      expect(card.categoryName, 'Vegetables');
      expect(card.waterNeed, 4);
      expect(card.sun, 'full_sun');
      expect(card.soilTypes, ['loam', 'clay']);
      expect(card.propagation, ['seed']);
      expect(card.spacingCm, 50);
      for (final text in [
        card.description,
        card.planting,
        card.care,
        card.seedSaving,
        card.tips,
      ]) {
        expect(text?.lang, 'en');
        expect(text?.isFallback, isFalse);
      }
      expect(card.careIntervals.map((c) => c.action), ['water', 'fertilise']);
      expect(card.plantTips, ['Tomatoes need a stake.']);
      expect(
        {for (final c in card.companions) c.name.text: c.isGood},
        {'Basil': true, 'Garlic': false},
      );
      expect(card.sources.single.licence, 'CC0');
      expect(remote.calls, 0);
    });

    test('without a garden zone the calendar shows all zones', () async {
      final card = (await repo.plantCard(tomatoId, lang: 'en'))!;
      expect(card.calendar.map((z) => z.zoneName), ['Coastal', 'Mountain']);
      expect(card.calendar.any((z) => z.isPreferred), isFalse);
      expect(card.calendar.first.entries.map((e) => e.activity), [
        'sow_indoors',
        'transplant',
        'harvest',
      ]);
    });

    test(
      'Given a gardener whose garden is in a climate zone, When they open a '
      'plant card from that garden, Then the calendar shows that zone first',
      () async {
        final card = (await repo.plantCard(
          tomatoId,
          lang: 'en',
          preferredZoneId: mountainZoneId,
        ))!;
        expect(card.calendar.map((z) => z.zoneName), ['Mountain', 'Coastal']);
        expect(card.calendar.first.isPreferred, isTrue);
      },
    );

    test('Given a plant with only Greek text and the UI in English, Then the '
        'Greek text is shown marked as not translated', () async {
      final card = (await repo.plantCard(oreganoId, lang: 'en'))!;
      expect(card.name, const LocalText('Ρίγανη', 'el', isFallback: true));
      expect(
        card.description,
        const LocalText('Η ρίγανη των βουνών.', 'el', isFallback: true),
      );
      expect(card.care?.isFallback, isTrue);

      final listed = await repo.search(
        const PlantQuery(lang: 'en', text: 'origanum'),
      );
      expect(listed.single.name.isFallback, isTrue);
    });

    test('a missing section falls back per section', () async {
      // Garlic has no seed saving text in either language.
      final card = (await repo.plantCard(garlicId, lang: 'el'))!;
      expect(card.seedSaving, isNull);
      expect(card.care, const LocalText('Λίγο νερό.', 'el', isFallback: false));
    });

    test('an unknown plant has no card', () async {
      expect(await repo.plantCard('no-such-plant', lang: 'el'), isNull);
    });
  });

  group('only published plants (UC-004)', () {
    // Snapshot A was built by the backend from a catalogue with the
    // published Ντομάτα and Σκόρδο and the draft Δυόσμος.
    test('Given only published plants are on the device, Then an unpublished '
        'plant never appears in search or cards', () async {
      final repo = await repositoryOn(snapshotA.path);

      expect(await names(repo, 'δυοσμος'), isEmpty);
      expect(await names(repo, 'mentha'), isEmpty);
      expect(await names(repo, ''), ['Ντομάτα', 'Σκόρδο']);
      final items = await repo.search(
        const PlantQuery(lang: 'el', inSeason: true, month: 11),
      );
      expect(items.map((i) => i.name.text), ['Ντομάτα', 'Σκόρδο']);
    });
  });
}
