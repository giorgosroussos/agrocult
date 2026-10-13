# Agrocult mobile app

Flutter app (Android; code kept iOS-compatible). Endpoints come only from
`--dart-define` values, never from code:

    cp config/development.example.json config/development.json   # git-ignored
    flutter run --dart-define-from-file=config/development.json

| key | meaning |
|---|---|
| `API_BASE_URL` | backend origin; the client calls `<API_BASE_URL>/api/v1/...` |
| `MAP_TILE_URL` | vector tile source for the garden map |

Layout: `lib/app/` (app shell, router, theme, locale), `lib/core/` (config, API
client, token storage, local database), `lib/l10n/` (ARB files), `lib/features/<feature>/`.

Checks: `flutter analyze` and `flutter test`. Generated code is committed;
regenerate with `dart run build_runner build` (drift) and `flutter gen-l10n`.
