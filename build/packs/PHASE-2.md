<!-- GENERATED — do not edit -->
# Pack PHASE-2 — Offline catalogue - curators publish plants in the panel, the app searches them offline in Greek, English and Greeklish

_design v1.2.0 · 567a799fd2d1_

Depends on: PHASE-1 · environment: development · components: CMP-Catalogue, CMP-AppCatalogue

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P2-T1 | Catalogue model | — | CMP-Catalogue |
| P2-T2 | Curation in the admin panel | P2-T1 | CMP-Catalogue |
| P2-T3 | Import commands | P2-T2 | CMP-Catalogue |
| P2-T4 | Catalogue snapshot and sync API | P2-T3 | CMP-Catalogue |
| P2-T5 | Local catalogue in the app | P2-T4 | CMP-AppCatalogue |
| P2-T6 | Search and plant card | P2-T5 | CMP-AppCatalogue |
| P2-T7 | Demo seeder | P2-T4 | CMP-Catalogue |

Execution waves: [P2-T1] → [P2-T2] → [P2-T3] → [P2-T4] → [P2-T5, P2-T7] → [P2-T6]

## Out of scope (do not build)

- Entering the 42 plants' content (curation work by the owner, not a task; P2-T7 demo content does not count toward it)
- Photo identification (PHASE-5)
- Gardens (PHASE-3)

## Use cases

#### UC-003 — Search catalogue (must)

Actors: ACT-Visitor, ACT-Gardener · Goal: Find plants by name, synonym or Greeklish, in any language, offline; filter by category and "in season now"

Main flow:
1. User types in the search box
2. Results update from the local catalogue on the device
3. User filters by category or 'in season now' and opens a plant card

Exceptions:
- No results: the app suggests photo identification
- No network: search works the same from the local catalogue

#### UC-004 — View plant card (must)

Actors: ACT-Visitor, ACT-Gardener · Goal: Read structured growing conditions, calendar per climate zone, planting, care, seed saving, tips and companions

Main flow:
1. User opens a plant from search, home or their garden
2. Sees identity, growing conditions, calendar, planting, description, care, seed saving, tips and companions in the UI language
3. Can tap 'Add to garden' (UC-002)

Exceptions:
- Text missing in the UI language: the other language is shown, marked as such
- No garden with a climate zone: the calendar shows all zones

#### UC-010 — Curate catalogue content (must)

Actors: ACT-Curator · Goal: Import facts from open sources, cross-check, review and publish plants

Main flow:
1. Curator signs in to the Laravel admin panel
2. Creates or imports a plant with its structured fields, translations, aliases, calendar per climate zone and companions
3. Records the source and licence of imported facts
4. Marks the plant reviewed and publishes it
5. Published changes reach the devices with the next catalogue sync

Exceptions:
- Required structured field missing: the plant cannot be published

## Entities

#### ENT-Plant — Catalogue plant with structured fields used by filters and notification rules

Owned by CMP-Catalogue · retention: — · audit: yes

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| scientific_name | string | string(255) | required, unique |
| gbif_id | integer | integer | unique |
| category_id | uuid | uuid | → ENT-PlantCategory, required |
| temp_min_c | decimal | decimal |  |
| temp_opt_c | decimal | decimal |  |
| temp_max_c | decimal | decimal |  |
| water_need | integer | integer |  |
| sun | enum | string |  |
| soil_types | json | jsonb |  |
| ph_min | decimal | decimal |  |
| ph_max | decimal | decimal |  |
| frost_hardiness | enum | string |  |
| propagation | json | jsonb |  |
| sow_depth_cm | decimal | decimal |  |
| spacing_cm | integer | integer |  |
| row_spacing_cm | integer | integer |  |
| days_to_harvest | integer | integer |  |
| status | enum | string | required |
| reviewed_by | uuid | uuid | → ENT-User |
| reviewed_at | timestamp | timestamptz |  |
| published_at | timestamp | timestamptz |  |
| updated_at | timestamp | timestamptz |  |

Relations: one-to-many → ENT-PlantTranslation (on delete cascade); one-to-many → ENT-PlantAlias (on delete cascade); one-to-many → ENT-PlantCalendar (on delete cascade); one-to-many → ENT-Companion (on delete cascade); one-to-many → ENT-CareInterval (on delete cascade); one-to-many → ENT-PlantPhoto (on delete cascade); one-to-many → ENT-FactSource (on delete cascade)

States: initial `draft`; allowed transitions: `draft -> in_review`, `in_review -> draft`, `in_review -> published`, `published -> draft`, `published -> archived`

#### ENT-PlantCategory — Curator-managed plant category with an optional parent (DATA-004)

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| code | string | string(255) | required, unique |
| name_el | string | string(255) | required |
| name_en | string | string(255) | required |
| parent_id | uuid | uuid | → ENT-PlantCategory |
| sort_order | integer | integer |  |

Relations: one-to-many → ENT-Plant (on delete restrict)

#### ENT-PlantTranslation — Texts of a plant in one language (one row per language, so a third language needs no schema change)

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| lang | enum | string | required |
| name | string | string(255) | required |
| description | text | text |  |
| planting | text | text |  |
| care | text | text |  |
| seed_saving | text | text |  |
| tips | text | text |  |

#### ENT-PlantAlias — Synonyms, local names and Greeklish spellings used by search

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| lang | enum | string |  |
| alias | string | string(255) | required |
| kind | enum | string |  |

#### ENT-ClimateZone — One of 4-5 named climate zones of Greece; drives the sowing calendar and season notifications (DATA-001)

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| code | string | string(255) | required, unique |
| name_el | string | string(255) | required |
| name_en | string | string(255) | required |
| description | text | text |  |
| rules | json | jsonb | required |

#### ENT-PlantCalendar — Month ranges for sowing, transplanting and harvest per climate zone

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| climate_zone_id | uuid | uuid | → ENT-ClimateZone, required |
| activity | enum | string | required |
| month_from | integer | integer | required |
| month_to | integer | integer | required |

#### ENT-Companion — Good or bad neighbour relation between two plants

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| other_plant_id | uuid | uuid | → ENT-Plant, required |
| relation | enum | string | required |

#### ENT-CareInterval — How often a care action is due for a plant, optionally only in some months (DEC-004)

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| action | enum | string | required |
| interval_days | integer | integer | required |
| month_from | integer | integer |  |
| month_to | integer | integer |  |

#### ENT-PlantPhoto — Catalogue photo with credit and licence

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| file_path | string | string(255) | required |
| credit | string | string(255) | required |
| licence | string | string(255) | required |
| source_url | url | string(2048) |  |

#### ENT-FactSource — Provenance of imported catalogue facts (SCOPE-001)

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| plant_id | uuid | uuid | → ENT-Plant, required |
| field | string | string(255) | required |
| source_name | string | string(255) | required |
| source_url | url | string(2048) |  |
| licence | string | string(255) | required |
| imported_at | timestamp | timestamptz |  |

#### ENT-Tip — Short tip or fact for the home screen, optionally tied to months, a climate zone or a plant

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| text_el | text | text | required |
| text_en | text | text | required |
| month_from | integer | integer |  |
| month_to | integer | integer |  |
| climate_zone_id | uuid | uuid | → ENT-ClimateZone |
| plant_id | uuid | uuid | → ENT-Plant |
| status | enum | string |  |

#### ENT-Settlement — Greek settlement for area search, derived from OpenStreetMap and bundled in the app

Owned by CMP-Catalogue · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| name_el | string | string(255) | required |
| name_en | string | string(255) |  |
| region | string | string(255) |  |
| lat | decimal | decimal | required |
| lon | decimal | decimal | required |

## Interfaces

#### PlantSourceImporter (INT-006: CMP-Catalogue ↔ EXT-006)

Mechanism: Artisan import commands run by the owner; results land as draft plants with FactSource rows

Operations:
- `import(source, scientific_name) -> DraftFacts`

Failure policy: timeout 30s, retries manual re-run, idempotency key —; when unavailable: The import stops with a message; nothing is published

## External systems in `development`

| id | name | mode | tool | config vars |
|---|---|---|---|---|
| EXT-006 | Open plant data sources | live |  | TREFLE_TOKEN |

## Constraints

- MUST record the source and licence of every imported catalogue fact  (SCOPE-001)
- SHOULD NOT import content from sources whose licence forbids commercial use  (SCOPE-001)
- MUST NOT hard-code plant categories in the app or the backend  (DATA-004)
- MUST NOT import plant catalogue data from Permapeople or any other share-alike or non-commercial source  (DEC-006)
- MUST include only published plants and tips in the catalogue snapshot  (ARCH-003)
- MUST bundle a catalogue snapshot in the app so that search works offline on first launch  (ARCH-003)
- MUST replace the local catalogue atomically; a failed download keeps the previous one  (ARCH-003)
- MUST reject ENT-Plant state transitions that are not listed in its state model
- Timestamps are stored in UTC.  (type timestamp)
- CMP-Catalogue MUST only depend on: CMP-Identity
- CMP-AppCatalogue MUST only depend on: CMP-AppCore
- MUST access EXT-006 only through PlantSourceImporter in CMP-Catalogue
- MUST apply timeout 30s to every EXT-006 call; retries: manual re-run

Standing constraints from deferred decisions (apply now):

- MUST allow an optional harvest quantity and unit on care log entries  (DATA-007, deferred)
- MUST keep a permanent daily weather summary (rain mm, min and max temperature) per weather cell  (DATA-007, deferred)
- MUST NOT show or export any data of one user to another user  (DATA-008, deferred)
- MUST NOT use Android-only plugins or APIs in the Flutter app without an iOS-compatible equivalent  (DEC-005, deferred)
- MUST keep iOS platform permissions text (location, camera, photos) up to date in the project  (DEC-005, deferred)
- MUST read all configuration from environment variables  (OPS-002, deferred)
- MUST store files only through the Laravel filesystem so that local and S3-compatible storage are interchangeable  (OPS-002, deferred)
- MUST log to stdout or a single log channel in structured format  (OPS-002, deferred)
- MUST NOT depend on provider-specific services in application code  (OPS-002, deferred)
- MUST model garden membership so that a garden can later have more than one user  (SCOPE-007, deferred)
- MUST keep the care log append-only and dated so that seasons can be compared  (SCOPE-007, deferred)
- SHOULD allow a garden plant to reference an optional bed  (SCOPE-007, deferred)
- MUST keep user identity separate from login credentials so that external identities can be linked to an existing account later  (SCOPE-009, deferred)
- MUST send email only through Laravel Mail  (EXT-004, deferred)

## Acceptance criteria (each needs a passing test)

- [UC-003] Given the catalogue contains 'Ντομάτα', When the user searches 'τοματα', Then 'Ντομάτα' is in the results
- [UC-003] Given the catalogue contains 'Ντομάτα', When the user searches 'ntomata' or 'domata', Then 'Ντομάτα' is in the results
- [UC-003] Given the alias 'ηδύοσμος' for 'Δυόσμος', When the user searches 'ηδυοσμος', Then 'Δυόσμος' is in the results
- [UC-003] Given the UI language is Greek, When the user searches 'basil', Then 'Βασιλικός' is in the results
- [UC-003] Given the device is offline, When the user searches 'σκόρδο', Then results appear without any network request
- [UC-003] Given a visitor without an account, Then search and filters work
- [UC-003] Given a garden in a climate zone where garlic sowing months include the current month, When the user filters 'in season now', Then garlic is listed
- [UC-004] Given a visitor without an account and no network, When they open a plant card, Then all text sections are shown from the local catalogue
- [UC-004] Given a signed-in gardener whose garden is in a climate zone, When they open a plant card from that garden, Then the calendar shows that zone first
- [UC-004] Given a plant with only Greek text and the UI in English, Then the Greek text is shown with a 'not translated' label
- [UC-004] Given only published plants are on the device, Then an unpublished plant never appears in search or cards
- [UC-010] Given a gardener account, When it opens the admin panel, Then access is denied
- [UC-010] Given a plant without a scientific name, Then it cannot be published
- [UC-010] Given a draft plant, Then it is not included in the catalogue sent to devices
- [UC-010] Given a plant is published, When a device syncs, Then the plant becomes searchable offline
- [ENT-Plant] Given any state, When a transition not in the state model is attempted, Then it is rejected and the state is unchanged
- [INT-006] Given EXT-006 is unavailable or times out, Then: The import stops with a message; nothing is published
- [phase] Given 3 published plants and 1 draft, When the snapshot is built, Then it contains exactly the 3 published plants
