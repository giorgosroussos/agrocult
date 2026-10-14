<!-- GENERATED — do not edit -->
# Pack PHASE-6 — Privacy and release readiness for Google Play

_design v1.4.0 · b5cc50419329_

Depends on: PHASE-4, PHASE-5 · environment: development · components: CMP-Privacy, CMP-AppHome

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P6-T1 | Export and account deletion API | — | CMP-Privacy |
| P6-T2 | Export and deletion screens | P6-T1 | CMP-AppHome |
| P6-T3 | Release readiness | — | CMP-AppCore |

Execution waves: [P6-T1, P6-T3] → [P6-T2]

## Out of scope (do not build)

- Choosing and setting up production hosting (OPS-002, before first production deploy)
- iOS release (DEC-005)

## Use cases

#### UC-014 — Delete account and export my data (must)

Actors: ACT-Gardener · Goal: GDPR rights to erasure and portability for gardens, plants, care log and photos

Main flow:
1. Gardener requests an export and receives a file with all their data
2. Gardener deletes the account after confirming

## Entities

_none_

## Constraints

- MUST publish a privacy policy before the first store release  (OPS-001)
- MUST declare approximate location, photos and email in the store data-safety forms  (OPS-001)
- CMP-Privacy MUST only depend on: CMP-Identity, CMP-Gardens, CMP-Identification, CMP-Notifications
- CMP-AppHome MUST only depend on: CMP-AppCore, CMP-AppCatalogue, CMP-AppGardens

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

- [UC-014] Given a gardener with 2 gardens, 5 plants and 10 care log entries, When they export, Then the file contains all 2 gardens, 5 plants and 10 entries
- [UC-014] Given a gardener deletes their account, Then their gardens, plants, care log, photos, notifications and push tokens no longer exist
- [phase] The app has a credits screen with OpenStreetMap, Open-Meteo and Pl@ntNet attributions
- [phase] A privacy policy is reachable from the app and the store listing
- [phase] Given the scheduler stops for more than 6 hours, Then the owner receives an email alert
