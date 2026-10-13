<!-- GENERATED — do not edit -->
# Pack PHASE-3 — My gardens - gardens with location and climate zone, plants in them, care log and next action

_design v1.0.0 · e80104843be7_

Depends on: PHASE-2 · environment: development · components: CMP-Weather, CMP-Gardens, CMP-AppGardens

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P3-T1 | Weather cells and climate zones | — | CMP-Weather |
| P3-T2 | Gardens API | P3-T1 | CMP-Gardens |
| P3-T3 | Gardens screens | P3-T2 | CMP-AppGardens |
| P3-T4 | Add, edit and remove garden plants | P3-T3 | CMP-AppGardens |
| P3-T5 | Care log and journal screens | P3-T4 | CMP-AppGardens |

Execution waves: [P3-T1] → [P3-T2] → [P3-T3] → [P3-T4] → [P3-T5]

## Out of scope (do not build)

- Forecasts and notifications (PHASE-4)
- Shared gardens (SCOPE-007)
- Season insights (DATA-007)

## Use cases

#### UC-001 — Manage gardens (must)

Actors: ACT-Gardener · Goal: Create gardens, each with its own approximate location

Main flow:
1. Gardener creates a garden and gives it a name
2. Sets the location by searching an area, picking a point on the map, or 'current position'
3. The app rounds the coordinates to 2 decimals before sending them
4. The server assigns the climate zone and weather cell
5. Gardener can rename the garden, change its location or delete it

Exceptions:
- Location permission denied when choosing 'current position': the app offers area search or map instead
- No location set: the garden is saved; weather notifications are off for it (SCOPE-004)
- Deleting a garden that has plants: the app asks for confirmation; plants and their care log are deleted with it

#### UC-002 — Add plant to garden (must)

Actors: ACT-Gardener · Goal: Add plants, trees or seeds with quantity, planting date and position in a few taps

Main flow:
1. Gardener finds a plant (search, plant card or photo identification) and taps 'Add'
2. Chooses the garden (preselected when they have only one)
3. Enters kind (plant, seed or tree), quantity, planting date, pot or ground, pot size, sun exposure
4. Saves; the plant appears in the garden with its next action

Exceptions:
- Visitor without an account taps 'Add': the app asks them to sign in or sign up and then continues the flow
- Gardener has no garden: the app creates one inline before adding

#### UC-007 — Log care action (must)

Actors: ACT-Gardener · Goal: Record watering, fertilising and other actions; derive the next action per plant

Main flow:
1. Gardener opens a plant in their garden and taps an action (watering, fertilising, pruning, weeding, spraying, harvest, other)
2. Optionally changes the date (default today), adds a note or a photo
3. Saves; the plant's next action is recalculated

Exceptions:
- Date in the future: rejected

#### UC-011 — Edit or remove garden plant (must)

Actors: ACT-Gardener · Goal: Change quantity, position or notes of a plant in a garden, or remove it

Main flow:
1. Gardener opens a plant in their garden
2. Edits quantity, planting date, pot or ground, pot size, sun exposure or notes, or removes it

#### UC-015 — View garden journal (should)

Actors: ACT-Gardener · Goal: See the care log of a garden or plant over time

## Entities

#### ENT-WeatherCell — Grid cell of about 10 km; one forecast per cell serves all its gardens

Owned by CMP-Weather · retention: — · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| lat | decimal | decimal | required |
| lon | decimal | decimal | required |
| elevation_m | integer | integer |  |
| winter_min_mean_c | decimal | decimal |  |
| last_frost_doy | integer | integer |  |
| first_frost_doy | integer | integer |  |
| climate_zone_id | uuid | uuid | → ENT-ClimateZone |

Relations: one-to-many → ENT-WeatherForecast (on delete cascade); one-to-many → ENT-WeatherDaily (on delete cascade)

#### ENT-Garden — A garden with its own approximate location, climate zone and weather cell

Owned by CMP-Gardens · retention: Until the garden or the account is deleted (immediate hard delete) · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| name | string | string(255) | required |
| lat | decimal | decimal | personal |
| lon | decimal | decimal | personal |
| climate_zone_id | uuid | uuid | → ENT-ClimateZone |
| weather_cell_id | uuid | uuid | → ENT-WeatherCell |
| created_at | timestamp | timestamptz |  |

Relations: one-to-many → ENT-GardenMember (on delete cascade); one-to-many → ENT-GardenPlant (on delete cascade)

#### ENT-GardenMember — Link between a user and a garden; MVP has exactly one owner per garden, shared gardens later (SCOPE-007)

Owned by CMP-Gardens · retention: Deleted with the garden or the user · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| garden_id | uuid | uuid | → ENT-Garden, required |
| user_id | uuid | uuid | → ENT-User, required |
| role | enum | string | required |

#### ENT-GardenPlant — A plant, seed or tree in a garden

Owned by CMP-Gardens · retention: Until the garden or the account is deleted · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| garden_id | uuid | uuid | → ENT-Garden, required |
| plant_id | uuid | uuid | → ENT-Plant, required |
| kind | enum | string | required |
| quantity | quantity | integer | required |
| planted_on | date | date | required |
| container | enum | string | required |
| pot_liters | decimal | decimal |  |
| sun_exposure | enum | string |  |
| notes | text | text | personal |
| archived_at | timestamp | timestamptz |  |

Relations: one-to-many → ENT-CareLog (on delete cascade)

#### ENT-CareLog — A dated care action; also the garden journal from which next actions and season comparisons come

Owned by CMP-Gardens · retention: Until the garden or the account is deleted · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| garden_plant_id | uuid | uuid | → ENT-GardenPlant, required |
| action | enum | string | required |
| done_on | date | date | required |
| harvest_qty | decimal | decimal |  |
| harvest_unit | enum | string |  |
| note | text | text | personal |
| photo_path | string | string(255) | personal |
| created_at | timestamp | timestamptz |  |

## Interfaces

#### WeatherProvider (INT-002: CMP-Weather ↔ EXT-002)

Mechanism: Laravel HTTP client in an Open-Meteo adapter behind WeatherProvider; called from queued jobs, one per weather cell

Operations:
- `forecast(lat, lon, days) -> DailyForecast[] (date, rain_mm, temp_min_c, temp_max_c)`
- `history(lat, lon, from, to) -> DailyWeather[]`
- `elevation(lat, lon) -> integer`

Failure policy: timeout 10s, retries 3, exponential backoff via queue (30s, 2m, 10m), idempotency key —; when unavailable: The last forecast of the cell is used if it is less than 12 hours old; otherwise weather rules are skipped for that run and the home screen shows 'weather currently unavailable' while care and season messages still work (UC-006, UC-008)

#### Map tiles (INT-005: CMP-Gardens ↔ EXT-005)

Mechanism: The mobile app loads vector tiles directly from MAP_TILE_URL; the settlement list is in the bundled catalogue snapshot

Operations:
- `GET {MAP_TILE_URL}/{z}/{x}/{y}`

Failure policy: timeout 10s, retries none (the map library retries tiles), idempotency key —; when unavailable: The map shows an offline message; area search from the settlement list still works

## External systems in `development`

| id | name | mode | tool | config vars |
|---|---|---|---|---|
| EXT-005 | Place search and map | live | OpenFreeMap public tiles | MAP_TILE_URL |

## Constraints

- MUST keep catalogue, calendar and care log usable for gardens without a location  (SCOPE-004)
- MUST derive a garden's climate zone from its weather cell, never from user input  (DATA-001)
- MUST store zone thresholds as data, not in code  (DATA-001)
- MUST compute cell climate metrics once per cell and reuse them  (DATA-001)
- MUST exclude archived garden plants from garden lists and from notification rules  (DATA-005)
- MUST NOT write ENT-Garden fields lat, lon to logs or error messages
- MUST NOT write ENT-GardenPlant fields notes to logs or error messages
- MUST NOT write ENT-CareLog fields note, photo_path to logs or error messages
- Quantities are integers unless the entity explicitly allows fractions.  (type quantity)
- Timestamps are stored in UTC.  (type timestamp)
- MUST enforce OWN-001 on every read and write of ENT-Garden: A gardener reads and changes only gardens where they have a GardenMember row
- MUST enforce OWN-002 on every read and write of ENT-GardenPlant: A gardener reads and changes only plants of gardens they are a member of
- MUST enforce OWN-003 on every read and write of ENT-CareLog: A gardener reads and changes only care log entries of plants in gardens they are a member of
- MUST enforce OWN-008 on every read and write of ENT-GardenMember: A gardener sees only memberships of gardens they are a member of
- MUST enforce OWN-009 on every read and write of ENT-Garden: A curator has no access to gardens, garden plants, care log or notifications of users
- CMP-Weather MUST only depend on: CMP-Catalogue
- CMP-Gardens MUST only depend on: CMP-Identity, CMP-Catalogue, CMP-Weather
- CMP-AppGardens MUST only depend on: CMP-AppCore, CMP-AppCatalogue
- MUST access EXT-002 only through WeatherProvider in CMP-Weather
- MUST apply timeout 10s to every EXT-002 call; retries: 3, exponential backoff via queue (30s, 2m, 10m)
- MUST access EXT-005 only through Map tiles in CMP-Gardens
- MUST apply timeout 10s to every EXT-005 call; retries: none (the map library retries tiles)

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

- [UC-001] Given a signed-in gardener, When they create garden 'Μπαλκόνι' at 37.98412, 23.72803, Then the stored location is exactly 37.98, 23.73
- [UC-001] Given a signed-in gardener, When they create a garden without a location, Then the garden is saved and has no climate zone and no weather cell
- [UC-001] Given a gardener who chose area search, Then the app never requests the device location permission
- [UC-001] Given a garden with 3 plants, When the gardener confirms deletion, Then the garden, its 3 plants and their care log entries no longer exist
- [UC-001] Given two gardens at 37.98, 23.73 and 37.99, 23.74, Then both are assigned the same weather cell
- [UC-002] Given a gardener with exactly 1 garden, When they tap 'Add' on a plant card, Then the garden is preselected and saving needs no other required field than quantity
- [UC-002] Given the add form, Then the planting date defaults to today and quantity defaults to 1
- [UC-002] Given the add form, When kind is 'ground', Then pot size is not asked
- [UC-002] Given a plant added with quantity 0, Then saving is rejected with a validation message
- [UC-007] Given a tomato with a fertilising interval of 14 days in the catalogue, When fertilising is logged on 2026-05-01, Then the next fertilising is due on 2026-05-15
- [UC-007] Given an action logged with date 2026-05-02 on 2026-05-05, Then it is stored with done_on 2026-05-02
- [UC-007] Given a date after today, Then saving is rejected
- [UC-011] Given a garden plant with 2 care log entries, When the gardener removes it, Then it no longer appears in the garden, no notifications are generated for it, and its 2 care log entries remain in the garden journal
- [OWN-001] Given a ROLE-Gardener user, When they read or modify an ENT-Garden record the rule does not grant them (A gardener reads and changes only gardens where they have a GardenMember row), Then access is denied and nothing changes
- [OWN-002] Given a ROLE-Gardener user, When they read or modify an ENT-GardenPlant record the rule does not grant them (A gardener reads and changes only plants of gardens they are a member of), Then access is denied and nothing changes
- [OWN-003] Given a ROLE-Gardener user, When they read or modify an ENT-CareLog record the rule does not grant them (A gardener reads and changes only care log entries of plants in gardens they are a member of), Then access is denied and nothing changes
- [OWN-008] Given a ROLE-Gardener user, When they read or modify an ENT-GardenMember record the rule does not grant them (A gardener sees only memberships of gardens they are a member of), Then access is denied and nothing changes
- [OWN-009] Given a ROLE-Curator user, When they read or modify an ENT-Garden record the rule does not grant them (A curator has no access to gardens, garden plants, care log or notifications of users), Then access is denied and nothing changes
- [INT-002] Given EXT-002 is unavailable or times out, Then: The last forecast of the cell is used if it is less than 12 hours old; otherwise weather rules are skipped for that run and the home screen shows 'weather currently unavailable' while care and season messages still work (UC-006, UC-008)
- [INT-005] Given EXT-005 is unavailable or times out, Then: The map shows an offline message; area search from the settlement list still works
