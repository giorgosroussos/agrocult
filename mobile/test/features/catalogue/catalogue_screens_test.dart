// UC-003 search screen and UC-004 plant card, driven through the app as a
// visitor (no account) on a device without network.
import 'dart:async';
import 'dart:io';

import 'package:agrocult/app/app.dart';
import 'package:agrocult/app/router.dart';
import 'package:agrocult/core/api/api_client.dart';
import 'package:agrocult/core/config/app_config.dart';
import 'package:agrocult/core/providers.dart';
import 'package:agrocult/features/catalogue/catalogue_providers.dart';
import 'package:agrocult/features/catalogue/catalogue_routes.dart';
import 'package:agrocult/features/catalogue/data/catalogue_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/fakes.dart';
import 'catalogue_fakes.dart';
import 'search_fixture.dart';

late CatalogueDatabase db;
late OfflineRemote remote;
late FakeHttpAdapter http;
late InMemoryTokenStorage tokens;

/// Mid November: coastal garlic is sown October to January.
final _today = DateTime(2026, 11, 14);

Future<void> _pumpApp(
  WidgetTester tester, {
  Locale locale = const Locale('el'),
  Set<String>? gardenZones,
}) async {
  // Tall enough that the whole plant card is built.
  tester.view.physicalSize = const Size(1000, 8000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStorageProvider.overrideWithValue(tokens),
        apiClientProvider.overrideWithValue(
          ApiClient(
            config: AppConfig.fromValues(
              apiBaseUrl: 'https://api.example.test',
              mapTileUrl: 'https://tiles.example.test',
            ),
            tokenStorage: tokens,
            httpClientAdapter: http,
          ),
        ),
        catalogueRemoteProvider.overrideWithValue(remote),
        localCatalogueProvider.overrideWith(() => FixedLocalCatalogue(db)),
        catalogueTodayProvider.overrideWithValue(() => _today),
        if (gardenZones != null)
          seasonClimateZonesProvider.overrideWithValue(gardenZones),
      ],
      child: AgrocultApp(
        locale: locale,
        featureRoutes: const [catalogueRoutes],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('catalogue.search')), text);
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, String route, {Object? args}) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  unawaited(navigator.pushNamed(route, arguments: args));
  await tester.pumpAndSettle();
}

/// Plant names in the result list, top to bottom.
List<String> _results(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(
    find.byKey(const Key('catalogue.plantName')),
  ))
    text.data!,
];

void _expectNoNetwork() {
  expect(http.requests, isEmpty);
  expect(remote.calls, 0);
}

void main() {
  setUp(() {
    db = openFixtureCopy(searchFixturePath);
    remote = OfflineRemote();
    http = FakeHttpAdapter()..error = const SocketException('offline');
    tokens = InMemoryTokenStorage();
  });
  tearDown(() => db.close());

  group('search (UC-003)', () {
    testWidgets('Given a visitor without an account, Then search and filters '
        'work', (tester) async {
      await _pumpApp(tester);
      expect(find.byKey(const Key('start.signIn')), findsOneWidget);

      await _tap(tester, 'start.catalogue');
      expect(_results(tester), hasLength(6));

      await _search(tester, 'ntomata');
      expect(_results(tester), ['Ντομάτα']);

      await _search(tester, '');
      await _tap(tester, 'catalogue.category.herbs');
      expect(_results(tester), ['Βασιλικός', 'Δυόσμος', 'Ρίγανη']);

      await _tap(tester, 'catalogue.category.all');
      await _tap(tester, 'catalogue.inSeason');
      // No garden: in season in any zone.
      expect(_results(tester), ['Σκόρδο']);

      await _tap(tester, 'catalogue.category.herbs');
      expect(find.byKey(const Key('catalogue.noResults')), findsOneWidget);
      _expectNoNetwork();
    });

    testWidgets("Given the device is offline, When the user searches 'σκόρδο', "
        'Then results appear without any network request', (tester) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.catalogue);

      await _search(tester, 'σκόρδο');

      expect(_results(tester), ['Σκόρδο']);
      _expectNoNetwork();
    });

    testWidgets('Greek, Greeklish, aliases and English names all find the '
        'plant', (tester) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.catalogue);

      for (final (query, plant) in [
        ('τοματα', 'Ντομάτα'),
        ('domata', 'Ντομάτα'),
        ('ηδυοσμος', 'Δυόσμος'),
        ('basil', 'Βασιλικός'),
      ]) {
        await _search(tester, query);
        expect(_results(tester), contains(plant), reason: query);
      }
    });

    testWidgets('Given a garden in a climate zone where garlic sowing months '
        "include the current month, When the user filters 'in season now', "
        'Then garlic is listed', (tester) async {
      await _pumpApp(tester, gardenZones: {coastalZoneId});
      await _open(tester, AppRoutes.catalogue);

      await _tap(tester, 'catalogue.inSeason');

      expect(_results(tester), ['Σκόρδο']);
    });

    testWidgets('a garden zone where garlic is not sown now does not list it', (
      tester,
    ) async {
      await _pumpApp(tester, gardenZones: {mountainZoneId});
      await _open(tester, AppRoutes.catalogue);

      await _tap(tester, 'catalogue.inSeason');

      expect(find.byKey(const Key('catalogue.noResults')), findsOneWidget);
    });

    testWidgets('no results suggest photo identification', (tester) async {
      await _pumpApp(tester, locale: const Locale('en'));
      await _open(tester, AppRoutes.catalogue);

      await _search(tester, 'banana');

      expect(find.text('No plants found'), findsOneWidget);
      expect(find.textContaining('from a photo'), findsOneWidget);
    });
  });

  group('plant card (UC-004)', () {
    testWidgets('Given a visitor without an account and no network, When they '
        'open a plant card, Then all text sections are shown from the local '
        'catalogue', (tester) async {
      await _pumpApp(tester);
      await _open(tester, AppRoutes.catalogue);
      await _search(tester, 'ντομάτα');
      await _tap(tester, 'catalogue.plant.$tomatoId');

      expect(find.byKey(const Key('plantCard.name')), findsOneWidget);
      expect(find.text('Solanum lycopersicum'), findsOneWidget);
      for (final section in [
        'conditions',
        'calendar',
        'planting',
        'description',
        'care',
        'seedSaving',
        'tips',
        'companions',
      ]) {
        expect(
          find.byKey(Key('plantCard.section.$section')),
          findsOneWidget,
          reason: section,
        );
      }
      for (final text in [
        'Η ντομάτα είναι το πιο αγαπημένο λαχανικό του κήπου.',
        'Μεταφύτευση όταν περάσει ο κίνδυνος παγετού.',
        'Πότισμα στη ρίζα, όχι στα φύλλα.',
        'Κρατήστε σπόρους από ώριμους καρπούς.',
        'Κορυφολόγηση στα 6 τσαμπιά.',
        '• Η ντομάτα θέλει στήριγμα.',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.text('Βασιλικός'), findsOneWidget); // good companion
      expect(find.text('Σκόρδο'), findsOneWidget); // bad companion
      expect(
        find.textContaining('Πλήρης ήλιος', findRichText: true),
        findsOneWidget,
      );
      expect(find.byKey(const Key('catalogue.notTranslated')), findsNothing);
      // Without a garden every zone is shown, none marked as the garden's.
      expect(find.byKey(Key('plantCard.zone.$coastalZoneId')), findsOneWidget);
      expect(find.byKey(Key('plantCard.zone.$mountainZoneId')), findsOneWidget);
      expect(find.text('Η ζώνη του κήπου σας'), findsNothing);
      _expectNoNetwork();
    });

    testWidgets('Given a signed-in gardener whose garden is in a climate zone, '
        'When they open a plant card from that garden, Then the calendar '
        'shows that zone first', (tester) async {
      tokens = InMemoryTokenStorage('device-token');
      await _pumpApp(tester, locale: const Locale('en'));
      expect(find.byKey(const Key('start.signOut')), findsOneWidget);

      await _open(
        tester,
        AppRoutes.plant,
        args: PlantCardArgs(tomatoId, climateZoneId: mountainZoneId),
      );

      final mountain = find.byKey(Key('plantCard.zone.$mountainZoneId'));
      final coastal = find.byKey(Key('plantCard.zone.$coastalZoneId'));
      expect(
        tester.getTopLeft(mountain).dy,
        lessThan(tester.getTopLeft(coastal).dy),
      );
      expect(
        find.descendant(
          of: mountain,
          matching: find.text("Your garden's zone"),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: mountain,
          matching: find.textContaining('March – April', findRichText: true),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Given a plant with only Greek text and the UI in English, '
        "Then the Greek text is shown with a 'not translated' label", (
      tester,
    ) async {
      await _pumpApp(tester, locale: const Locale('en'));
      await _open(tester, AppRoutes.plant, args: oreganoId);

      expect(find.text('Ρίγανη'), findsWidgets);
      for (final text in [
        'Η ρίγανη των βουνών.',
        'Μοσχεύματα την άνοιξη.',
        'Δεν θέλει σχεδόν πότισμα.',
        'Μαζέψτε τους σπόρους το καλοκαίρι.',
        'Κόψτε την όταν ανθίσει.',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      // The name and the five texts are each marked.
      expect(find.text('Not translated'), findsNWidgets(6));
    });

    testWidgets('a translated plant in English has no label', (tester) async {
      await _pumpApp(tester, locale: const Locale('en'));
      await _open(tester, AppRoutes.plant, args: basilId);

      expect(find.text('The basil of the yard.'), findsOneWidget);
      expect(find.text('Not translated'), findsNothing);
    });

    testWidgets('a Greek-only plant is marked in the English result list', (
      tester,
    ) async {
      await _pumpApp(tester, locale: const Locale('en'));
      await _open(tester, AppRoutes.catalogue);
      await _search(tester, 'rigani');

      expect(_results(tester), ['Ρίγανη']);
      expect(find.text('Not translated'), findsOneWidget);
    });

    testWidgets('a companion opens its own card', (tester) async {
      await _pumpApp(tester, locale: const Locale('en'));
      await _open(tester, AppRoutes.plant, args: tomatoId);

      await _tap(tester, 'plantCard.companion.$basilId');

      expect(find.text('The basil of the yard.'), findsOneWidget);
    });
  });

  group('only published plants (UC-004)', () {
    testWidgets('Given only published plants are on the device, Then an '
        'unpublished plant never appears in search or cards', (tester) async {
      await db.close();
      // Built by the backend: published Ντομάτα and Σκόρδο, draft Δυόσμος.
      db = openFixtureCopy(snapshotA.path);
      await _pumpApp(tester);
      await _open(tester, AppRoutes.catalogue);

      await _search(tester, 'δυόσμος');
      expect(find.byKey(const Key('catalogue.noResults')), findsOneWidget);
      await _search(tester, '');
      expect(_results(tester), ['Ντομάτα', 'Σκόρδο']);

      // Even a direct link to a plant that is not on the device opens no card.
      await _open(tester, AppRoutes.plant, args: mintId);
      expect(
        find.text('Αυτό το φυτό δεν υπάρχει στον κατάλογο.'),
        findsOneWidget,
      );
    });
  });

  group('routes', () {
    test('the catalogue handles only its own routes', () {
      RouteSettings to(String name, [Object? args]) =>
          RouteSettings(name: name, arguments: args);

      expect(catalogueRoutes(to(AppRoutes.catalogue)), isNotNull);
      expect(catalogueRoutes(to(AppRoutes.plant, 'id')), isNotNull);
      expect(
        catalogueRoutes(to(AppRoutes.plant, const PlantCardArgs('id'))),
        isNotNull,
      );
      expect(catalogueRoutes(to(AppRoutes.plant)), isNull);
      expect(catalogueRoutes(to(AppRoutes.signIn)), isNull);
    });

    testWidgets('without the catalogue routes the app shows page not found', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [tokenStorageProvider.overrideWithValue(tokens)],
          child: const AgrocultApp(locale: Locale('en')),
        ),
      );
      await tester.pumpAndSettle();
      await _open(tester, AppRoutes.catalogue);

      expect(find.byType(NotFoundScreen), findsOneWidget);
    });
  });
}
