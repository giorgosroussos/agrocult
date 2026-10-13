import 'dart:convert';
import 'dart:io';

import 'package:agrocult/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, Object?>;

Set<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('Greek and English ARB files define the same messages', () {
    final en = _messageKeys(_arb('en'));
    final el = _messageKeys(_arb('el'));

    expect(en, isNotEmpty);
    expect(el, en);
  });

  test('no message is left empty in either language', () {
    for (final locale in ['el', 'en']) {
      final arb = _arb(locale);
      for (final key in _messageKeys(arb)) {
        expect(
          arb[key],
          isA<String>().having((s) => s.trim(), 'text', isNotEmpty),
          reason: '$locale:$key',
        );
      }
    }
  });

  test('the app supports exactly Greek and English', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'el', 'en'},
    );
  });
}
