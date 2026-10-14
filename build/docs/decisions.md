<!-- GENERATED from design/ — do not edit. Rebuild with tools/design/build.py -->
# Decision record

_Generated document · design v1.3.0 · source cd829a248c19_


## Scope

### SCOPE-001 — Personal project, possibly commercial later · decided

> Engineer: “Είναι προσωπικό project, ίσως αργότερα και εμπορικό.”

**Decision:** Built as a personal project; the design keeps a later commercial release possible.

**Why:** Permapeople is CC BY-SA (share-alike), the Perenual free tier is non-commercial only, and Pl@ntNet commercial terms must be confirmed before any commercial release. Keeping provenance per fact lets incompatible content be removed later.

**Constraints for implementation:**
- `MUST record the source and licence of every imported catalogue fact`
- `SHOULD NOT import content from sources whose licence forbids commercial use`

_affects UC-005, UC-010_

### SCOPE-002 — Catalogue without sign-in, everything else with an account · decided

> Engineer: “Θα άφηνα χωρίς κάποια σύνδεση την αναζήτηση φυτών κ.λπ από το περιεχόμενο της εφαμοργής. Όλες οι υπόλοιπες δραστηριότητες απαιτούν σύνδεση καθώς απαιτούν ένα είδος συσχέτησης.”

**Decision:** Catalogue search and plant cards work without an account. Gardens, garden plants, care log, notifications and settings stored on the server require a signed-in account.

**Constraints for implementation:**
- `MUST allow catalogue search and plant cards without sign-in`
- `MUST require an authenticated account for every endpoint that reads or writes gardens, garden plants, care log or notifications`

_affects UC-003, UC-004, UC-012_

### SCOPE-003 — Location belongs to the garden, not the user · decided

> Engineer: “Η τοποθεσία ανήκει στον κήπο, όχι στον χρήστη: ο καιρός που μετράει είναι του κήπου, όχι του κινητού.”

**Decision:** Each garden has its own location; weather, climate zone and notifications are computed per garden. A user can have many gardens.

**Constraints for implementation:**
- `MUST compute weather, climate zone and notifications from the garden's location, never from the device's current position`

### SCOPE-004 — App works without a location · decided

> Engineer: “Χωρίς τοποθεσία η εφαρμογή λειτουργεί ως κατάλογος και ημερολόγιο, χωρίς ειδοποιήσεις καιρού.”

**Decision:** A garden without a location still supports catalogue, calendar and care log; only weather notifications are disabled.

**Constraints for implementation:**
- `MUST keep catalogue, calendar and care log usable for gardens without a location`

### SCOPE-005 — Few, timely notifications · decided

> Engineer: “Λίγες και επίκαιρες: το πολύ μία σύνοψη τη μέρα ανά κήπο, εκτός από επείγοντα (παγετός, καύσωνας).”

**Decision:** At most one summary push per garden per day, sent in the morning local time; frost and heatwave alerts may be sent in addition.

**Constraints for implementation:**
- `MUST NOT send more than one summary notification per garden per day`
- `MUST write every notification in the user's stored language`

### SCOPE-006 — Quality over quantity in the catalogue · decided

> Engineer: “Στόχος MVP: 30–50 φυτά, άριστα ελεγμένα, όχι 1.000 μέτρια.”

**Decision:** The MVP catalogue contains 30-50 plants, each reviewed by a human before publication.

### SCOPE-007 — Post-MVP ideas the data model must support · deferred

> Engineer: “Δεν είναι για το MVP, αλλά αξίζει να σχεδιαστεί η βάση ώστε να τις σηκώνει.”

**Deferred to:** after MVP · trigger: MVP released and in use

**Requirements:**
- Beds and crop rotation (what was planted where, per year)
- Vacation mode with a pre-departure checklist from the forecast
- Spraying alerts (wind/rain in the next hours)
- Harvest log (kg/pieces per plant and season)
- Shared garden with invited members
- Seed exchange by area
- Home-screen widget
- Disease diagnosis (possible premium)
- Freemium: free with one garden; subscription for many gardens, diagnosis, season log

**Constraints for implementation:**
- `MUST model garden membership so that a garden can later have more than one user`
- `MUST keep the care log append-only and dated so that seasons can be compared`
- `SHOULD allow a garden plant to reference an optional bed`

### SCOPE-008 — Settings - English docs, development environment only · decided

> Engineer: “Ας κρατήσουμε την γλώσσα στα έγγραφα, αγγλικά με ένα μόνο περιβάλλον development για τώρα”

**Decision:** Design files and generated docs in English. Only a development environment for now; staging/production are added by amendment before the first release.

### SCOPE-009 — Sign-in with external providers · deferred

> Engineer: “δεν θα πρόσθετα ακόμα (οχι για το MVP) σύνδεση με εξωτερικούς παρόχους”

**Decision:** MVP uses email and password only.

**Deferred to:** after MVP · trigger: Sign-up friction observed, or commercial release

**Requirements:**
- Google sign-in
- Sign in with Apple (required by the App Store when any third-party login exists)

**Constraints for implementation:**
- `MUST keep user identity separate from login credentials so that external identities can be linked to an existing account later`

### SCOPE-010 — Catalogue curation through a Laravel admin panel · decided

> Engineer: “Την επιμέλεια του καταλόγου θα γίνεται από κάποιο panel διαχειριστικό στο Laravel”

**Decision:** Curators edit, review and publish catalogue content in an admin panel inside the Laravel backend. The panel package is chosen in area 6.

_affects UC-010_

## Actors

### DEC-002 — Photo identification needs an account, 10 per day · decided · source: inferred

> Engineer: “1 ναι 10”

**Decision:** Photo identification requires sign-in and is limited to 10 identifications per gardener per day.

**Why:** Keeps usage within the Pl@ntNet free quota of 500/day and makes the per-user limit enforceable.

**Constraints for implementation:**
- `MUST require an authenticated account for photo identification`
- `MUST limit photo identification to 10 per gardener per day, configurable`

_affects UC-005_

### DEC-003 — Urgent alerts immediately, outside quiet hours · decided · source: inferred

> Engineer: “2 β”

**Decision:** Frost and heatwave alerts are sent as soon as detected; during 22:00-07:00 Europe/Athens they wait until 07:00. Summaries go at 07:30 Europe/Athens.

**Constraints for implementation:**
- `MUST NOT send any push notification between 22:00 and 07:00 Europe/Athens`

_affects UC-008_

### DEC-004 — Use case defaults confirmed · decided · source: default

> Engineer: “προεπιλογές ok”

**Decision:** Summary at 07:30 Europe/Athens; no empty summaries; cached forecast usable up to 12 h; weather thresholds in configuration; care reminders from per-plant per-action intervals in the catalogue; email verification and non-revealing auth errors; first-launch language from device (Greek, else English); add-plant form defaults; immediate hard delete of garden or account after confirmation; no future dates in the care log.

**Constraints for implementation:**
- `MUST read weather rule thresholds from configuration`
- `MUST NOT use a cached forecast older than 12 hours for weather rules`
- `MUST NOT reveal in any auth response whether an email is registered`

_affects UC-002, UC-007, UC-008, UC-012, UC-013, UC-014_

## External

### DEC-001 — Weather provider · decided · source: inferred

> Engineer: “1 α”

**Decision:** Open-Meteo free API while the project is personal; switch to its paid plan or MET Norway before any commercial release.

**Why:** No key, ECMWF/ICON models suit Greece, historical archive for frost dates, generous free limit.

**Rejected:**
- MET Norway (no historical archive)
- OpenWeatherMap (lower free limit)

_affects EXT-002_

### DEC-005 — Android first, iOS later · deferred · source: inferred

> Engineer: “2 α”

**Decision:** The MVP is released on Android only; iOS follows later.

**Deferred to:** after Android MVP release · trigger: Apple Developer account and a Mac for builds are available

**Requirements:**
- Apple Developer account
- APNs key in Firebase
- Mac or cloud macOS build

**Constraints for implementation:**
- `MUST NOT use Android-only plugins or APIs in the Flutter app without an iOS-compatible equivalent`
- `MUST keep iOS platform permissions text (location, camera, photos) up to date in the project`

### DEC-006 — No Permapeople data · decided · source: inferred

> Engineer: “4 συμφωνώ”

**Decision:** Permapeople is not used as a data source; companion data comes from OpenFarm (CC0).

**Constraints for implementation:**
- `MUST NOT import plant catalogue data from Permapeople or any other share-alike or non-commercial source`

_affects EXT-006, UC-010_

## Data

### DATA-001 — Climate zones computed per weather cell from historical data · decided · source: inferred

> Engineer: “1 β”

**Decision:** Each weather cell gets climate metrics from the Open-Meteo historical archive (mean winter minimum temperature, mean last spring frost and first autumn frost dates, elevation). The metrics map the cell to one of 4-5 named climate zones; gardens take the zone of their cell. Zone thresholds and names are curator-managed data.

**Why:** Distinguishes Crete from Florina and two villages of the same prefecture at different altitudes, while curators fill calendars for only 4-5 zones.

**Rejected:**
- fixed zones by region and altitude: too coarse

**Constraints for implementation:**
- `MUST derive a garden's climate zone from its weather cell, never from user input`
- `MUST store zone thresholds as data, not in code`
- `MUST compute cell climate metrics once per cell and reuse them`

_affects ENT-ClimateZone, ENT-WeatherCell, ENT-Garden_

### DATA-002 — Plants in the first catalogue · decided · source: inferred

> Engineer: “Η λίστα είναι οκ”

**Decision:** 42 plants in 10 categories (list in rationale).

**Why:** Fruit vegetables: tomato, pepper, aubergine, okra. Cucurbits: courgette, cucumber, watermelon, melon. Leafy and brassicas: lettuce, spinach, cabbage, broccoli, chard, rocket. Roots and bulbs: potato, carrot, beetroot, onion, garlic, leek. Legumes: green beans, broad beans, peas. Aromatic herbs: basil, mint, oregano, thyme, rosemary, parsley, dill, lavender. Citrus: lemon, orange, mandarin. Fruit trees: olive, fig, pomegranate, almond, apricot. Vines: grapevine. Flowers: geranium, marigold (Tagetes).

### DATA-003 — The owner reviews content in the MVP · decided · source: inferred

> Engineer: “3 α”

**Decision:** The owner reviews and publishes catalogue content in the MVP; an agronomist joins as curator when available. Weather thresholds remain initial values until an agronomist checks them.

_affects UC-010_

### DATA-004 — Plant categories as curator-managed data · decided

> Engineer: “θα ήθελα επίσης τα φυτά να κατηγοριοποιούνται (π.χ. αρρωματικά, εσπεριδοειδή, καρποφόρα, κ.λπ)”

**Decision:** Categories are a catalogue table with Greek and English names and an optional parent, so curators can add or regroup them. Each plant has one primary category; search filters by category.

**Constraints for implementation:**
- `MUST NOT hard-code plant categories in the app or the backend`

### DATA-005 — Removing a garden plant archives it · decided · source: inferred

> Engineer: “4 α”

**Decision:** Removing a plant from a garden sets archived_at; it disappears from the garden and produces no notifications, its care log stays for season comparison. Deleting a garden or an account still hard-deletes everything.

**Constraints for implementation:**
- `MUST exclude archived garden plants from garden lists and from notification rules`

_affects UC-011, ENT-GardenPlant_

### DATA-006 — Data model defaults · decided · source: default

> Engineer: “Για της προεπιλογές είμαι εντάξει.”

**Decision:** UUID keys; UTC timestamps; ISO language codes; identification photos not stored, results kept 30 days; forecasts kept 7 days, notifications 90 days; user data until account deletion; owners may edit or delete their care log entries; tips in Greek and English; audit trail on catalogue plant changes.

**Constraints for implementation:**
- `MUST NOT store identification photos after the provider call`
- `MUST use UUID primary keys`

### DATA-007 — Personal season insights · deferred · source: inferred

> Engineer: “Θα μπορούσαμε εφόσον κρατάμε δεδομένα για κάθε λογαριασμό να τα χρησιμοποιούμε για να προσφέρουμε στον χρήστη κάποιες πληροφορίες σχετικά με την δραστηριότητα του μέσα στο χρόνο/σεζόν ;”

**Decision:** A 'My season' view with the user's own statistics (planting dates year over year, care actions per month and plant, watering vs rain, harvest per plant and season) comes after the MVP; the MVP stores what it needs.

**Deferred to:** after MVP · trigger: Users have at least one full season of data

**Requirements:**
- Only the user's own data
- Comparison across seasons
- Watering compared with actual rain

**Constraints for implementation:**
- `MUST allow an optional harvest quantity and unit on care log entries`
- `MUST keep a permanent daily weather summary (rain mm, min and max temperature) per weather cell`

_affects ENT-CareLog, ENT-WeatherDaily_

### DATA-008 — Anonymous regional insights from all users · deferred

> Engineer: “2 ναι”

**Decision:** Aggregated, anonymised activity by area (e.g. 'gardeners near you are sowing garlic now') is a post-MVP idea.

**Deferred to:** after MVP · trigger: Enough users per area

**Requirements:**
- Anonymisation
- Minimum number of users per area before showing any figure
- Disclosure in the privacy policy

**Constraints for implementation:**
- `MUST NOT show or export any data of one user to another user`

## Security

### SEC-001 — Authentication of the mobile app and the admin panel · superseded · source: inferred

> Engineer: “οκ”

**Decision:** Mobile app: email and password, Laravel Sanctum API token per device without automatic expiry, revoked on sign-out and on password change. The owner is the only admin in the MVP: manages curator and user accounts but has no access to users' gardens through the panel. Admin panel: session login on the web with TOTP MFA required for curators and admins.

**Constraints for implementation:**
- `MUST hash passwords with argon2id`
- `MUST issue one API token per device and revoke it on sign-out`
- `MUST revoke all API tokens of a user when the password changes`
- `MUST require TOTP MFA for every admin panel account`
- `MUST rate-limit sign-in to 5 attempts per minute per email and IP`
- `MUST NOT allow gardener accounts to sign in to the admin panel`

_affects ROLE-Gardener, ROLE-Curator_

### SEC-002 — GDPR scope · decided · source: inferred

> Engineer: “οκ”

**Decision:** Personal data: email, approximate garden locations (~1 km), notes, care log photos, push tokens. Lawful basis: contract (providing the service). Export and erasure through UC-014. Privacy policy before release (EXT-007). Hosting in the EU (area 8).

**Constraints for implementation:**
- `MUST NOT write emails, coordinates, notes or tokens to logs`
- `MUST NOT send personal data to Pl@ntNet or Open-Meteo beyond the photo and rounded coordinates`
- `MUST store user photos in private storage, served only through authorised, expiring URLs`

### SEC-003 — Security baseline · decided · source: default

> Engineer: “οκ”

**Decision:** OWASP Top 10 baseline, TLS everywhere, security headers on the admin panel, dependency vulnerability scanning in CI, secrets only in environment variables, no personal data in logs, uploaded images validated by type and size and stripped of EXIF metadata.

**Constraints for implementation:**
- `MUST strip EXIF metadata (including GPS) from every uploaded photo`
- `MUST reject uploads that are not JPEG, PNG or WebP or are larger than 5 MB`
- `MUST read secrets only from environment variables`

### SEC-004 — Minimum age 15 · decided · source: inferred

> Engineer: “ναι είμαστε οκ με την περιοχή 6 καθώς και με τα ηλικιακά όρια”

**Decision:** Accounts require a minimum age of 15 (GDPR art. 8 as set by Greek law); sign-up asks the user to confirm it.

**Constraints for implementation:**
- `MUST require the user to confirm they are at least 15 years old at sign-up`

_affects UC-012_

### SEC-005 — Authentication of the mobile app and the admin panel, with TOTP storage and recovery · decided

> Engineer: “2a, agreed”

**Decision:** As SEC-001: mobile app with email and password and a Laravel Sanctum API token per device without automatic expiry, revoked on sign-out and on password change; the owner is the only admin in the MVP and has no access to users' gardens through the panel; admin panel with web session login and TOTP MFA required for curators and admins. Added: the TOTP secret and one-time recovery codes are stored on the user (Filament built-in app authentication). A curator or admin without a confirmed secret must set up TOTP at the first panel sign-in. A lost device is recovered with a recovery code, or by the admin clearing the user's MFA.

**Why:** CR-P1-T5-1: the design had no storage for the TOTP secret. Recovery codes keep the single admin able to regain access without server-side intervention.

**Rejected:**
- No recovery codes: the only admin could regain access only through the server (artisan or SQL)

**Constraints for implementation:**
- `MUST hash passwords with argon2id`
- `MUST issue one API token per device and revoke it on sign-out`
- `MUST revoke all API tokens of a user when the password changes`
- `MUST require TOTP MFA for every admin panel account`
- `MUST rate-limit sign-in to 5 attempts per minute per email and IP`
- `MUST NOT allow gardener accounts to sign in to the admin panel`
- `MUST store the TOTP secret and recovery codes encrypted at rest and never expose them in API responses or logs`
- `MUST force a curator or admin without a confirmed TOTP secret to set it up before any other panel page`
- `MUST make each recovery code usable only once`
- `MUST let the admin reset another account's MFA, and MUST NOT let a curator do so`

_affects ROLE-Gardener, ROLE-Curator · supersedes SEC-001 · since v1.1.0_

## Architecture

### ARCH-001 — Backend platform and language · decided

> Engineer: “Ας δούμε κάτι σε php Laravel.”

**Decision:** Own backend in PHP Laravel (API + scheduled worker). Versions and supporting services are fixed in area 6.

**Why:** Single developer; chosen by the engineer's preference and skills.

**Rejected:**
- Supabase + worker
- FastAPI
- NestJS
- Dart server

### ARCH-002 — Single repository · decided

> Engineer: “1 με ένα repo”

**Decision:** Backend and mobile app live in one repository (backend/, mobile/) next to the design.

### ARCH-003 — Catalogue shipped to devices as a SQLite snapshot · decided · source: inferred

> Engineer: “4 α”

**Decision:** On every publish the server builds a versioned SQLite snapshot of the published catalogue (with search keys). The app bundles an initial snapshot, checks the current version on start and downloads the whole snapshot when it changed.

**Constraints for implementation:**
- `MUST include only published plants and tips in the catalogue snapshot`
- `MUST bundle a catalogue snapshot in the app so that search works offline on first launch`
- `MUST replace the local catalogue atomically; a failed download keeps the previous one`

_affects UC-003, UC-004, UC-010_

### ARCH-004 — Riverpod for state management · decided · source: inferred

> Engineer: “2 πάμε με την δική σου επιλογή”

**Decision:** The Flutter app uses Riverpod.

### ARCH-005 — Dependency versions corrected after foundation work · decided

> Engineer: “^7.0 εγκρίνεται, A για τον χάρτη, α για Flutter”

**Decision:** kreait/laravel-firebase ^7.0 (6.x does not support Laravel 13). vector_map_tiles pinned to 9.0.0-beta.13 (no stable 9.x; 8.x needs flutter_map 7). Flutter 3.44, the newest version verified available.

**Why:** Versions in the baseline were proposed without verification; the foundation tasks found them unresolvable (CR-P1-T1-1, CR-P1-T2-1). The beta map library only serves the garden location picker, and area search covers the same need if the map fails.

**Rejected:**
- raster tiles with flutter_map only: OpenFreeMap serves only vector tiles; OSM tile policy forbids app use; keyed providers have limits
- flutter_map 7 with vector_map_tiles 8: outdated, a second migration later

**Constraints for implementation:**
- `MUST use flutter_map and vector_map_tiles only inside the GardenLocationMap widget`
- `MUST move vector_map_tiles to a stable release (^9.0.0) before the first store release, if one exists`

_affects CMP-AppGardens, CMP-Notifications, EXT-003, EXT-005 · since v1.0.1_

## Integrations

### DEC-007 — Failure behaviour of identification and summaries · decided · source: inferred

> Engineer: “ok”

**Decision:** Only identifications that returned a provider result count against the 10/day limit. A morning summary not pushed by 10:00 Europe/Athens is not pushed and stays visible in the app. Calls to third parties are logged with duration and outcome, never personal data. Mocks simulate timeouts and errors.

**Constraints for implementation:**
- `MUST NOT count failed identification attempts against the daily limit`
- `MUST NOT push a summary after 10:00 Europe/Athens`
- `MUST log third-party calls with duration and outcome and without personal data`
- `MUST make every external-service fake able to simulate a timeout and an error`

_affects INT-001, INT-003, UC-005, UC-008_

## Operations

### OPS-001 — App store distribution · decided · source: inferred

**Decision:** Android app distributed through Google Play (one-time developer fee); iOS through the App Store later (DEC-005). Both need a privacy policy and data-safety / privacy labels declaring location, photos and email.

**Constraints for implementation:**
- `MUST publish a privacy policy before the first store release`
- `MUST declare approximate location, photos and email in the store data-safety forms`

### OPS-002 — Production hosting · deferred · source: inferred

> Engineer: “συμφωνώ με τις προτάσεις σου”

**Why:** Candidates at decision time: Oracle Cloud Always Free (EU region) or a small Hetzner VPS.

**Deferred to:** before first production deploy · trigger: MVP feature-complete in development

**Requirements:**
- EU region (SEC-002)
- Free or near-free (ORG-001)
- PHP 8.3, PostgreSQL 18, a long-running queue worker and cron (scheduler)
- ~1 vCPU / 2 GB RAM at launch; ~10 GB database and ~20 GB photo storage in the first year
- Public HTTPS endpoint with certificate

**Constraints for implementation:**
- `MUST read all configuration from environment variables`
- `MUST store files only through the Laravel filesystem so that local and S3-compatible storage are interchangeable`
- `MUST log to stdout or a single log channel in structured format`
- `MUST NOT depend on provider-specific services in application code`

### OPS-003 — Code on GitHub, CI with GitHub Actions · decided

> Engineer: “ο κώδικας θα ζεί σε GitHub”

**Decision:** The repository is hosted on GitHub; CI runs on GitHub Actions on every push and pull request.

**Constraints for implementation:**
- `MUST pass every CI stage before a branch is merged`

### OPS-004 — Docker development environment · decided

> Engineer: “Για το περιβάλλον development θα προτιμούσα docker”

**Decision:** Development runs in Docker via Laravel Sail: PHP 8.3, PostgreSQL 18 and the queue worker and scheduler as services. The Flutter app runs on the host against the Sail API.

**Constraints for implementation:**
- `MUST run backend commands (artisan, composer, tests) inside the Sail containers`
- `MUST keep the Docker setup in backend/compose.yaml`
