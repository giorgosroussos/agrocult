<!-- GENERATED from design/ — do not edit. Rebuild with tools/design/build.py -->
# Design rules — Agrocult (design v1.4.0 · b5cc50419329)

Mobile app (Android/iOS) that tells amateur gardeners in Greece what to do today for their own plants, based on the local weather at each of their gardens. It combines a plant catalogue with practical growing instructions for the Mediterranean climate and a personal garden with smart, weather-driven notifications.

## How you work in this repository
1. You work on one task id at a time. Get your brief with `python tools/design/build.py brief <TASK-ID>` and read `build/briefs/<TASK-ID>.md`. It contains everything the task needs. Do not read design/ wholesale; open a single design item only when the brief references it and you need detail.
2. design/, build/ (except build/briefs/), tools/design/ and this file are the source of truth. Never edit them; edits are blocked.
3. If the spec is unclear, contradictory or missing something, STOP. Do not improvise. Set your task to `blocked` and write `progress/requests/CR-<TASK-ID>-<n>.yaml` (e.g. CR-P1-T1-1, so parallel tasks never collide) (id, raised_by: implementation-agent, task, problem, affects, proposal, status: open).
4. Record progress only in `progress/tasks/<TASK-ID>.yaml`: status (in_progress | blocked | ready_to_merge), commit, and handoff (max 5 lines: what now exists and where). No narrative logs; history lives in git.
5. A task is finished when every acceptance criterion in the brief has a passing test (including the negative ones), lint and architecture checks pass, and `python tools/design/validate.py` passes. Then set status `ready_to_merge` and stop.
6. Never merge, rebase, cherry-pick, pull or resolve conflicts. The engineer integrates.
7. Never deploy to production or use production credentials.
8. Reference the task id in every commit message, e.g. `P2-T3: add payment gateway mock`.

## Stack
- backend: Laravel 13.8
- backend: PHP 8.3
- database: PostgreSQL 18
- queue: Laravel queue (database driver) 13.8
- worker: Laravel scheduler + queue worker 13.8
- other: Filament 5.7
- frontend: Riverpod 3.0
- frontend: Flutter 3.44
- storage: Laravel filesystem (local in development 13.8
- architecture style: modular-monolith

## Global constraints
- MUST NOT build: Disease diagnosis from photos (later, possibly premium)  (non-goal)
- MUST NOT build: Community features and seed exchange  (non-goal)
- MUST NOT build: Moisture sensors and smart irrigation devices  (non-goal)
- MUST NOT build: A third language  (non-goal)
- MUST NOT build: Web version  (non-goal)
- MUST NOT build: Background location tracking  (non-goal)
- SHOULD use only services with a free tier sufficient for development and the first users  (ORG-001)
- MUST NOT store identification photos after the provider call  (DATA-006)
- MUST use UUID primary keys  (DATA-006)
- MUST allow catalogue search and plant cards without sign-in  (SCOPE-002)
- MUST require an authenticated account for every endpoint that reads or writes gardens, garden plants, care log or notifications  (SCOPE-002)
- MUST compute weather, climate zone and notifications from the garden's location, never from the device's current position  (SCOPE-003)
- MUST NOT write emails, coordinates, notes or tokens to logs  (SEC-002)
- MUST NOT send personal data to Pl@ntNet or Open-Meteo beyond the photo and rounded coordinates  (SEC-002)
- MUST store user photos in private storage, served only through authorised, expiring URLs  (SEC-002)
- MUST strip EXIF metadata (including GPS) from every uploaded photo  (SEC-003)
- MUST reject uploads that are not JPEG, PNG or WebP or are larger than 5 MB  (SEC-003)
- MUST read secrets only from environment variables  (SEC-003)
- MUST NOT add runtime dependencies outside the approved list: laravel/framework@^13.8, laravel/sanctum@^4.0, filament/filament@^5.7, kreait/laravel-firebase@^7.0, intervention/image@^3.0, flutter_riverpod@^3.0.0, drift@^2.28.0, dio@^5.9.0, intl@^0.20.0, flutter_map@^8.0.0, vector_map_tiles@9.0.0-beta.13, firebase_messaging@^16.0.0, image_picker@^1.2.0, flutter_image_compress@^2.4.0, geolocator@^14.0.0, flutter_secure_storage@^9.2.0. New ones need a change request.
- MUST read every external endpoint and credential from configuration; never hardcode them
- MUST NOT perform live payments, send real emails or call live external systems outside production
- Shared hotspot files (touch only when your task lists them): `backend/composer.json`, `backend/bootstrap/providers.php`, `backend/routes/console.php`, `mobile/pubspec.yaml`, `mobile/lib/l10n/app_el.arb`, `mobile/lib/l10n/app_en.arb`, `mobile/lib/app/router.dart`, `backend/database/seeders/DatabaseSeeder.php`, `mobile/lib/main.dart`

## Conventions
- One repository: backend/ (Laravel) and mobile/ (Flutter); design/, build/, progress/, tools/ at the root
- Backend modules live in backend/app/Modules/<Module>/ and register their own routes, providers, migrations and Filament resources
- A module uses another module only through its public service classes or events, never its models directly
- REST JSON API under /api/v1; errors as RFC 9457 problem details; list endpoints are paginated
- Backend tests with Pest; Pint formatting; Larastan level 6; deptrac enforces may_depend_on
- Mobile: feature-first folders in mobile/lib/features/<feature>/; Riverpod for state; drift for the local catalogue with FTS5 search
- Search keys (accent-free, lower-case, Greeklish transliteration) are computed on the server when the catalogue snapshot is built
- UI strings in ARB files with intl; Greek and English
- External services only behind interfaces: WeatherProvider, PlantIdentifier, PushSender; tests always use fakes
- All dependencies are installed in the foundation phase; a new runtime dependency needs a change request
- The map is used only through one app widget (GardenLocationMap) in CMP-AppGardens; no other code imports flutter_map or vector_map_tiles
- mobile/lib/main.dart is the composition root: the only file that may import both lib/app (CMP-AppCore) and lib/features; it passes each feature's FeatureRoutes to AgrocultApp
- Route names live in AppRoutes (mobile/lib/app/routes.dart, CMP-AppCore) so the shell can navigate by name; features register the screen builders for their routes
