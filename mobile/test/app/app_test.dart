import 'dart:async';

import 'package:agrocult/app/app.dart';
import 'package:agrocult/app/locale.dart';
import 'package:agrocult/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppLocale', () {
    test('Greek device language gives Greek', () {
      expect(resolveAppLocale([const Locale('el', 'GR')]), const Locale('el'));
    });

    test('any other device language gives English', () {
      expect(resolveAppLocale([const Locale('de')]), const Locale('en'));
      expect(resolveAppLocale([const Locale('en', 'US')]), const Locale('en'));
      expect(resolveAppLocale(const []), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });

    test('only the preferred language counts', () {
      expect(
        resolveAppLocale([const Locale('fr'), const Locale('el')]),
        const Locale('en'),
      );
    });
  });

  testWidgets('starts on the start screen in Greek on a Greek device', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = [const Locale('el', 'GR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: AgrocultApp()));
    await tester.pumpAndSettle();

    expect(find.text('Καλώς ήρθατε'), findsOneWidget);
    expect(find.text('Agrocult'), findsOneWidget);
  });

  testWidgets('shows English on a non-Greek device', (tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('it', 'IT')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: AgrocultApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('an unknown route shows the not-found screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AgrocultApp(locale: Locale('en'))),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(navigator.pushNamed('/does-not-exist'));
    await tester.pumpAndSettle();

    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text('Page not found'), findsOneWidget);
  });

  test('router knows the start route', () {
    final route = AppRouter.onGenerateRoute(
      const RouteSettings(name: AppRoutes.start),
    );
    expect(route, isA<MaterialPageRoute<Object?>>());
    expect(route.settings.name, AppRoutes.start);
  });
}
