import 'dart:ui';

/// UI languages of the app.
const supportedAppLocales = [Locale('el'), Locale('en')];

/// Greek when the device prefers Greek, English for any other language.
Locale resolveAppLocale(List<Locale>? deviceLocales) {
  final preferred = (deviceLocales == null || deviceLocales.isEmpty)
      ? null
      : deviceLocales.first;
  if (preferred?.languageCode == 'el') return const Locale('el');
  return const Locale('en');
}
