<!-- GENERATED — do not edit -->
# Pack PHASE-5 — Photo identification through our server

_design v1.4.0 · b5cc50419329_

Depends on: PHASE-3 · environment: development · components: CMP-Identification, CMP-AppCatalogue

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P5-T1 | Identification API | — | CMP-Identification |
| P5-T2 | Identification screens | P5-T1 | CMP-AppCatalogue |

Execution waves: [P5-T1] → [P5-T2]

## Out of scope (do not build)

- Disease diagnosis (non-goal)

## Use cases

#### UC-005 — Identify plant by photo (must)

Actors: ACT-Gardener · Goal: Get 2-3 likely species with confidence, confirm one, and open or add it

Main flow:
1. Gardener takes or picks a photo
2. The app resizes it to about 1024 px and uploads it to our server
3. The server calls the identification provider, limited to local flora by the garden location
4. The app shows 2-3 candidates with confidence; when started from a garden, the gardener's own plants are listed first
5. Gardener confirms one; the app opens its plant card or the add flow

Exceptions:
- Candidate not in our catalogue: shown with its scientific name and marked 'not in catalogue'; cannot be added
- Provider unavailable or daily quota reached: the app says identification is temporarily unavailable
- Gardener's own limit reached: the app says when it resets
- No candidate above the minimum confidence: the app says it could not identify the plant

## Entities

#### ENT-Identification — A photo identification request; used for the 10/day limit and result caching

Owned by CMP-Identification · retention: 30 days; the photo itself is not stored after the provider call · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| user_id | uuid | uuid | → ENT-User, required |
| garden_id | uuid | uuid | → ENT-Garden |
| candidates | json | jsonb |  |
| chosen_plant_id | uuid | uuid | → ENT-Plant |
| created_at | timestamp | timestamptz | required |

## Interfaces

#### PlantIdentifier (INT-001: CMP-Identification ↔ EXT-001)

Mechanism: Laravel HTTP client in a Pl@ntNet adapter behind PlantIdentifier; called synchronously from the identification request after resizing and EXIF stripping

Operations:
- `identify(image, lang, lat?, lon?) -> Candidate[] (scientific_name, gbif_id, confidence)`

Failure policy: timeout 15s, retries 1, after 1s, idempotency key —; when unavailable: The app shows 'identification is temporarily unavailable' (UC-005); the photo is discarded; the failed attempt does not count against the 10/day limit

## External systems in `development`

| id | name | mode | tool | config vars |
|---|---|---|---|---|
| EXT-001 | Pl@ntNet identification API | live | Pl@ntNet free key | PLANTNET_API_KEY |

## Constraints

- MUST require an authenticated account for photo identification  (DEC-002)
- MUST limit photo identification to 10 per gardener per day, configurable  (DEC-002)
- MUST NOT count failed identification attempts against the daily limit  (DEC-007)
- MUST NOT push a summary after 10:00 Europe/Athens  (DEC-007)
- MUST log third-party calls with duration and outcome and without personal data  (DEC-007)
- MUST make every external-service fake able to simulate a timeout and an error  (DEC-007)
- Timestamps are stored in UTC.  (type timestamp)
- MUST enforce OWN-006 on every read and write of ENT-Identification: A gardener reads only their own identification requests
- CMP-Identification MUST only depend on: CMP-Identity, CMP-Catalogue, CMP-Gardens
- CMP-AppCatalogue MUST only depend on: CMP-AppCore
- MUST access EXT-001 only through PlantIdentifier in CMP-Identification
- MUST apply timeout 15s to every EXT-001 call; retries: 1, after 1s

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

- [UC-005] Given a 4000x3000 photo, When it is uploaded, Then the uploaded image's longest side is at most 1024 px
- [UC-005] Given a provider result with 5 candidates, Then at most 3 are shown, each with a confidence percentage
- [UC-005] Given identification started from a garden containing tomato, When tomato is among the candidates, Then tomato is shown first
- [UC-005] Given a candidate with GBIF id matching a catalogue plant, Then it links to that plant card
- [UC-005] Given the provider is down, Then the app shows 'temporarily unavailable' and no error code
- [UC-005] Given the identification results screen, Then the Pl@ntNet attribution is visible
- [UC-005] Given the mobile app build, Then it contains no identification provider API key
- [UC-005] Given a gardener who made 10 identifications today, When they request an 11th, Then it is refused with the time the limit resets
- [UC-005] Given a visitor without an account, When they tap photo identification, Then the app asks them to sign in
- [UC-005] Given a gardener with 9 identifications today, When the 10th fails because the provider is down, Then they can still make 1 more identification today
- [OWN-006] Given a ROLE-Gardener user, When they read or modify an ENT-Identification record the rule does not grant them (A gardener reads only their own identification requests), Then access is denied and nothing changes
- [INT-001] Given EXT-001 is unavailable or times out, Then: The app shows 'identification is temporarily unavailable' (UC-005); the photo is discarded; the failed attempt does not count against the 10/day limit
