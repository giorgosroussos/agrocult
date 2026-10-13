<!-- GENERATED — do not edit -->
# Pack PHASE-4 — What to do today - forecasts, weather x plant rules, morning summaries, urgent alerts and the home screen

_design v1.0.0 · e80104843be7_

Depends on: PHASE-3 · environment: development · components: CMP-Weather, CMP-Notifications, CMP-AppHome

## Tasks

| task | title | depends on | writes |
|---|---|---|---|
| P4-T1 | Forecast refresh | — | CMP-Weather |
| P4-T2 | Notification rules | — | CMP-Notifications |
| P4-T3 | Push delivery | P4-T2 | CMP-Notifications |
| P4-T4 | Today feed API | P4-T2 | CMP-Notifications |
| P4-T5 | Home, notifications and settings screens | P4-T3, P4-T4 | CMP-AppHome |

Execution waves: [P4-T1] → [P4-T2] → [P4-T3] → [P4-T4] → [P4-T5]

## Out of scope (do not build)

- Spraying alerts and vacation mode (SCOPE-007)
- Home-screen widget (SCOPE-007)

## Use cases

#### UC-006 — View today's home screen (must)

Actors: ACT-Visitor, ACT-Gardener · Goal: See garden weather, today's notifications, garden summary, seasonal ideas and a tip

Main flow:
1. Gardener opens the app
2. Sees, per garden with a location, today's weather and today's notifications
3. Sees a summary of gardens with the next actions
4. Sees seasonal ideas for the garden's climate zone and a tip

Exceptions:
- No network: the last loaded home data is shown with its time
- No garden: the screen invites the gardener to create one

#### UC-008 — Receive weather and care notifications (must)

Actors: ACT-Worker, ACT-Gardener · Goal: Morning push per garden from rain, heatwave, frost, care and season rules

Main flow:
1. The worker runs every few hours and fetches one forecast per weather cell that has at least one garden
2. Applies the rules (rain, heatwave, frost, care due, season) to each garden's plants
3. Builds at most one summary per garden per day in the user's language and sends it at 07:30 Europe/Athens
4. Frost and heatwave alerts are sent as soon as the worker detects them, except during quiet hours 22:00-07:00, when they wait until 07:00
5. Gardener opens the notification and lands on the garden

Exceptions:
- Weather provider unavailable: the last cached forecast is used if it is less than 12 hours old, otherwise weather rules are skipped for that run
- Push token invalid: the token is removed; the notification stays visible in the app
- Nothing to say for a garden: no summary is sent

#### UC-009 — Change settings (must)

Actors: ACT-Gardener · Goal: Language (Greek/English), gardens and location, notification preferences

Main flow:
1. Gardener changes the language; the UI switches and the server stores it for notifications
2. Turns notification types on or off
3. Manages gardens and their locations (UC-001)

## Entities

#### ENT-WeatherForecast — Cached forecast of one weather cell

Owned by CMP-Weather · retention: 7 days · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| weather_cell_id | uuid | uuid | → ENT-WeatherCell, required |
| fetched_at | timestamp | timestamptz | required |
| forecast | json | jsonb | required |

#### ENT-WeatherDaily — Permanent daily weather summary per cell, for season insights (DATA-007)

Owned by CMP-Weather · retention: Permanent (not personal data) · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| weather_cell_id | uuid | uuid | → ENT-WeatherCell, required |
| day | date | date | required |
| rain_mm | decimal | decimal |  |
| temp_min_c | decimal | decimal |  |
| temp_max_c | decimal | decimal |  |

#### ENT-Notification — A notification produced by the rules, shown in the app and pushed to devices

Owned by CMP-Notifications · retention: 90 days, and deleted with the account · audit: no

| attribute | type | storage | notes |
|---|---|---|---|
| id | uuid | uuid | primary |
| user_id | uuid | uuid | → ENT-User, required |
| garden_id | uuid | uuid | → ENT-Garden |
| type | enum | string | required |
| for_date | date | date | required |
| payload | json | jsonb |  |
| scheduled_for | timestamp | timestamptz |  |
| sent_at | timestamp | timestamptz |  |
| read_at | timestamp | timestamptz |  |

States: initial `scheduled`; allowed transitions: `scheduled -> sent`, `scheduled -> skipped`, `sent -> read`

## Interfaces

#### WeatherProvider (INT-002: CMP-Weather ↔ EXT-002)

Mechanism: Laravel HTTP client in an Open-Meteo adapter behind WeatherProvider; called from queued jobs, one per weather cell

Operations:
- `forecast(lat, lon, days) -> DailyForecast[] (date, rain_mm, temp_min_c, temp_max_c)`
- `history(lat, lon, from, to) -> DailyWeather[]`
- `elevation(lat, lon) -> integer`

Failure policy: timeout 10s, retries 3, exponential backoff via queue (30s, 2m, 10m), idempotency key —; when unavailable: The last forecast of the cell is used if it is less than 12 hours old; otherwise weather rules are skipped for that run and the home screen shows 'weather currently unavailable' while care and season messages still work (UC-006, UC-008)

#### PushSender (INT-003: CMP-Notifications ↔ EXT-003)

Mechanism: kreait/laravel-firebase behind PushSender; sent from queued jobs

Operations:
- `send(token, title, body, data) -> SendResult (sent | invalid_token | failed)`

Failure policy: timeout 10s, retries 3, exponential backoff via queue, idempotency key —; when unavailable: Notifications stay in the app's notification list; pushes are retried; a summary push not sent by 10:00 Europe/Athens is dropped and stays in-app only; an urgent alert that cannot be sent before 22:00 waits for 07:00

## External systems in `development`

| id | name | mode | tool | config vars |
|---|---|---|---|---|
| EXT-002 | Weather forecast provider (Open-Meteo) | live | Open-Meteo free API (no key) | OPEN_METEO_BASE_URL |
| EXT-003 | Push notifications (FCM, APNs through FCM) | live | Firebase dev project | FIREBASE_CREDENTIALS |

## Constraints

- MUST NOT send more than one summary notification per garden per day  (SCOPE-005)
- MUST write every notification in the user's stored language  (SCOPE-005)
- MUST NOT send any push notification between 22:00 and 07:00 Europe/Athens  (DEC-003)
- MUST read weather rule thresholds from configuration  (DEC-004)
- MUST NOT use a cached forecast older than 12 hours for weather rules  (DEC-004)
- MUST NOT reveal in any auth response whether an email is registered  (DEC-004)
- MUST NOT count failed identification attempts against the daily limit  (DEC-007)
- MUST NOT push a summary after 10:00 Europe/Athens  (DEC-007)
- MUST log third-party calls with duration and outcome and without personal data  (DEC-007)
- MUST make every external-service fake able to simulate a timeout and an error  (DEC-007)
- MUST reject ENT-Notification state transitions that are not listed in its state model
- Timestamps are stored in UTC.  (type timestamp)
- MUST enforce OWN-004 on every read and write of ENT-Notification: A gardener reads only notifications where user_id is their own id
- CMP-Weather MUST only depend on: CMP-Catalogue
- CMP-Notifications MUST only depend on: CMP-Identity, CMP-Catalogue, CMP-Weather, CMP-Gardens
- CMP-AppHome MUST only depend on: CMP-AppCore, CMP-AppCatalogue, CMP-AppGardens
- MUST access EXT-002 only through WeatherProvider in CMP-Weather
- MUST apply timeout 10s to every EXT-002 call; retries: 3, exponential backoff via queue (30s, 2m, 10m)
- MUST access EXT-003 only through PushSender in CMP-Notifications
- MUST apply timeout 10s to every EXT-003 call; retries: 3, exponential backoff via queue

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

- [UC-006] Given 2 gardens with locations, Then the home screen shows the weather of each garden, not of the device position
- [UC-006] Given a garden without a location, Then it appears in the summary without weather
- [UC-006] Given the device is offline, Then the last loaded data is shown with the time it was loaded
- [UC-006] Given a visitor without an account, Then the home screen shows seasonal ideas and a tip for Greece in general and an invitation to sign up, and no weather
- [UC-008] Given a forecast of 12 mm rain in the next 24 h for a garden, Then the summary contains the 'do not water' message for that garden
- [UC-008] Given a forecast of 9 mm rain in the next 24 h, Then no rain message is generated
- [UC-008] Given a forecast maximum of 38 °C, Then a heatwave message is generated; given 37 °C, Then it is not
- [UC-008] Given a forecast minimum of 2 °C and a frost-sensitive plant in the garden, Then a frost alert is generated; given 3 °C, Then it is not
- [UC-008] Given 2 gardens in the same weather cell, When the worker runs, Then the weather provider is called once for that cell
- [UC-008] Given a garden that already received a summary today, When the worker runs again, Then no second summary is sent
- [UC-008] Given a user whose language is English, Then the notification text is in English
- [UC-008] Given a garden without a location, Then no weather message is generated for it
- [UC-008] Given the thresholds 10 mm, 38 °C and 2 °C, Then they are read from configuration, not hard-coded
- [UC-008] Given a frost alert detected at 15:00, Then it is sent at 15:00 without waiting for the next summary
- [UC-008] Given a frost alert detected at 23:00, Then it is sent at 07:00 the next morning
- [UC-008] Given the summary for a garden, Then it is sent at 07:30 Europe/Athens
- [UC-008] Given a garden with no messages for today, Then no summary is sent
- [UC-008] Given the push service is down from 07:30 to 10:30, Then that day's summary is not pushed and is visible in the app
- [UC-009] Given a first launch on a device set to Greek, Then the UI is in Greek; on any other device language, Then English
- [UC-009] Given the gardener switches to English, Then the stored user language on the server is 'en'
- [UC-009] Given the gardener turned off care reminders, Then no care messages are included in their summaries
- [OWN-004] Given a ROLE-Gardener user, When they read or modify an ENT-Notification record the rule does not grant them (A gardener reads only notifications where user_id is their own id), Then access is denied and nothing changes
- [ENT-Notification] Given any state, When a transition not in the state model is attempted, Then it is rejected and the state is unchanged
- [INT-002] Given EXT-002 is unavailable or times out, Then: The last forecast of the cell is used if it is less than 12 hours old; otherwise weather rules are skipped for that run and the home screen shows 'weather currently unavailable' while care and season messages still work (UC-006, UC-008)
- [INT-003] Given EXT-003 is unavailable or times out, Then: Notifications stay in the app's notification list; pushes are retried; a summary push not sent by 10:00 Europe/Athens is dropped and stays in-app only; an urgent alert that cannot be sent before 22:00 waits for 07:00
