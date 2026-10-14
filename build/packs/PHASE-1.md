<!-- GENERATED — do not edit -->
# Pack PHASE-1 — Walking skeleton - backend and app run, CI enforces every check, accounts and admin panel work

_design v1.2.0 · 567a799fd2d1_

Depends on: none · environment: development · components: CMP-Identity, CMP-AppCore

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P1-T1 | Backend skeleton in Docker | — | — |
| P1-T2 | Mobile app skeleton | — | CMP-AppCore |
| P1-T3 | CI pipeline | P1-T1, P1-T2 | — |
| P1-T4 | Accounts API | P1-T1 | CMP-Identity |
| P1-T5 | Admin panel with MFA | P1-T4 | CMP-Identity |
| P1-T6 | Auth screens in the app | P1-T2, P1-T4 | CMP-AppCore |

Execution waves: [P1-T1, P1-T2] → [P1-T3, P1-T4] → [P1-T5, P1-T6]

## Out of scope (do not build)

- Catalogue (PHASE-2)
- Social login (SCOPE-009)
- Production hosting (OPS-002)
- iOS build (DEC-005)

## Use cases

#### UC-012 — Sign up and sign in (must)

Actors: ACT-Visitor, ACT-Gardener · Goal: Create an account with email and password, and sign in on a device

Main flow:
1. Visitor enters email and password
2. Confirms the email through a link
3. Signs in; the device registers for push

Exceptions:
- Email already registered: the app offers sign-in or password reset
- Wrong password: generic error that does not reveal whether the email exists

#### UC-013 — Reset password (must)

Actors: ACT-Gardener · Goal: Regain access to the account by email

Main flow:
1. Gardener requests a reset with their email
2. Receives a one-time link and sets a new password

## Entities

#### ENT-User — Account of a gardener or curator

Owned by CMP-Identity · retention: Until account deletion (immediate hard delete, DEC-004) · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| email | email | string(254) | required, unique, personal |
| password_hash | string | string(255) | required, sensitive |
| email_verified_at | timestamp | timestamptz |  |
| role | enum | string | required |
| language | enum | string | required |
| notification_prefs | json | jsonb |  |
| app_authentication_secret | text | text | sensitive |
| app_authentication_recovery_codes | json | jsonb | sensitive |
| created_at | timestamp | timestamptz |  |

Relations: one-to-many → ENT-GardenMember (on delete cascade); one-to-many → ENT-PushToken (on delete cascade); one-to-many → ENT-Notification (on delete cascade); one-to-many → ENT-Identification (on delete cascade)

#### ENT-PushToken — Device push token of a user

Owned by CMP-Identity · retention: Until sign-out, invalidation by FCM, or account deletion · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| user_id | uuid | uuid | → ENT-User, required |
| token | string | string(255) | required, unique, personal |
| platform | enum | string |  |
| last_seen_at | timestamp | timestamptz |  |

## Interfaces

#### Laravel Mail (INT-004: CMP-Identity ↔ EXT-004)

Mechanism: Laravel Mail over SMTP, queued; Mailtrap sandbox in development

Operations:
- `sendVerification(user_id)`
- `sendPasswordReset(user_id)`

Failure policy: timeout 15s, retries 5, exponential backoff via queue, idempotency key —; when unavailable: Emails stay queued and are retried; the user can request a new verification or reset email from the app

## External systems in `development`

| id | name | mode | tool | config vars |
|---|---|---|---|---|
| EXT-004 | Transactional email | catcher | Mailtrap Email Sandbox (free plan) | MAIL_* |

## Constraints

- MUST hash passwords with argon2id  (SEC-005)
- MUST issue one API token per device and revoke it on sign-out  (SEC-005)
- MUST revoke all API tokens of a user when the password changes  (SEC-005)
- MUST require TOTP MFA for every admin panel account  (SEC-005)
- MUST rate-limit sign-in to 5 attempts per minute per email and IP  (SEC-005)
- MUST NOT allow gardener accounts to sign in to the admin panel  (SEC-005)
- MUST store the TOTP secret and recovery codes encrypted at rest and never expose them in API responses or logs  (SEC-005)
- MUST force a curator or admin without a confirmed TOTP secret to set it up before any other panel page  (SEC-005)
- MUST make each recovery code usable only once  (SEC-005)
- MUST let the admin reset another account's MFA, and MUST NOT let a curator do so  (SEC-005)
- MUST require the user to confirm they are at least 15 years old at sign-up  (SEC-004)
- MUST pass every CI stage before a branch is merged  (OPS-003)
- MUST run backend commands (artisan, composer, tests) inside the Sail containers  (OPS-004)
- MUST keep the Docker setup in backend/compose.yaml  (OPS-004)
- MUST read weather rule thresholds from configuration  (DEC-004)
- MUST NOT use a cached forecast older than 12 hours for weather rules  (DEC-004)
- MUST NOT reveal in any auth response whether an email is registered  (DEC-004)
- MUST NOT write ENT-User fields email, password_hash, app_authentication_secret, app_authentication_recovery_codes to logs or error messages
- MUST encrypt ENT-User fields password_hash, app_authentication_secret, app_authentication_recovery_codes at rest
- MUST NOT write ENT-PushToken fields token to logs or error messages
- Emails are validated and compared case-insensitively.  (type email)
- Timestamps are stored in UTC.  (type timestamp)
- MUST enforce OWN-005 on every read and write of ENT-PushToken: A gardener registers and removes only their own push tokens
- MUST enforce OWN-007 on every read and write of ENT-User: A gardener reads, changes, exports and deletes only their own account
- CMP-Identity MUST only depend on: no other component
- CMP-AppCore MUST only depend on: no other component
- MUST access EXT-004 only through Laravel Mail in CMP-Identity
- MUST apply timeout 15s to every EXT-004 call; retries: 5, exponential backoff via queue

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

- [UC-012] Given an email that is already registered, When a visitor signs up with it, Then no second account is created
- [UC-012] Given a wrong password, Then the error message is the same as for an unknown email
- [UC-013] Given a reset link already used once, When it is opened again, Then it is rejected
- [UC-013] Given an unknown email, When a reset is requested, Then the response is the same as for a known email
- [OWN-005] Given a ROLE-Gardener user, When they read or modify an ENT-PushToken record the rule does not grant them (A gardener registers and removes only their own push tokens), Then access is denied and nothing changes
- [OWN-007] Given a ROLE-Gardener user, When they read or modify an ENT-User record the rule does not grant them (A gardener reads, changes, exports and deletes only their own account), Then access is denied and nothing changes
- [INT-004] Given EXT-004 is unavailable or times out, Then: Emails stay queued and are retried; the user can request a new verification or reset email from the app
- [phase] Given a fresh clone, When the engineer runs Sail up, Then the API, PostgreSQL 18, the queue worker and the scheduler start
- [phase] GET /up returns 200
- [phase] CI on GitHub Actions runs Pint, Larastan, Pest, deptrac, flutter analyze, flutter test, composer audit and tools/design/ci_check.py on every push
- [phase] Given an unknown API route, Then the response is an RFC 9457 problem details document
- [phase] Given the app on a Greek device, Then the sign-in screen is in Greek
