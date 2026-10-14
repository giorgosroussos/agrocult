<!-- GENERATED from design/ — do not edit. Rebuild with tools/design/build.py -->
# Scope

_Generated document · design v1.4.0 · source b5cc50419329_


**Category:** public-app

## Problem

Existing apps (Planta, PictureThis, Greg) target indoor plants or the climate of North America and Northern Europe. Encyclopedic plant information is everywhere; nothing adapts it to my plants, my area and today's weather, in Greek.

## Goals

- Tell the user what to do today for each of their plants, from the forecast at the garden's location
- Add a plant to a garden (search, choose garden, quantity/date/position) in a few taps
- At most one summary notification per garden per day, except urgent alerts (frost, heatwave)
- Catalogue search works offline and instantly, accent- and case-insensitive, with Greeklish and synonyms, across all languages
- MVP catalogue of 30-50 plants, all expert-reviewed
- Greek and English from the first release

## Non-goals

- Disease diagnosis from photos (later, possibly premium)
- Community features and seed exchange
- Moisture sensors and smart irrigation devices
- A third language
- Web version
- Background location tracking

## Scale

| dimension | expected |
|---|---|
| users | tens of thousands (future target, not for launch) |
| concurrent | ~500 at morning notification peak |
| data_volume | ~50 catalogue plants; ~10 plants and a few care-log entries per week per user |

## Project constraints

- Single developer (the owner)
- No deadline
- Budget: free tiers wherever possible
- Personal project first; may become commercial later

## Environments

- development

## Decisions

| id | title | status | decision |
|---|---|---|---|
| SCOPE-001 | Personal project, possibly commercial later | decided | Built as a personal project; the design keeps a later commercial release possible. |
| SCOPE-002 | Catalogue without sign-in, everything else with an account | decided | Catalogue search and plant cards work without an account. Gardens, garden plants, care log, notifications and settings stored on the server require a signed-in account. |
| SCOPE-003 | Location belongs to the garden, not the user | decided | Each garden has its own location; weather, climate zone and notifications are computed per garden. A user can have many gardens. |
| SCOPE-004 | App works without a location | decided | A garden without a location still supports catalogue, calendar and care log; only weather notifications are disabled. |
| SCOPE-005 | Few, timely notifications | decided | At most one summary push per garden per day, sent in the morning local time; frost and heatwave alerts may be sent in addition. |
| SCOPE-006 | Quality over quantity in the catalogue | decided | The MVP catalogue contains 30-50 plants, each reviewed by a human before publication. |
| SCOPE-007 | Post-MVP ideas the data model must support | deferred | → after MVP |
| SCOPE-008 | Settings - English docs, development environment only | decided | Design files and generated docs in English. Only a development environment for now; staging/production are added by amendment before the first release. |
| SCOPE-009 | Sign-in with external providers | deferred | MVP uses email and password only. |
| SCOPE-010 | Catalogue curation through a Laravel admin panel | decided | Curators edit, review and publish catalogue content in an admin panel inside the Laravel backend. The panel package is chosen in area 6. |
