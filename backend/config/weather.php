<?php

return [

    // INT-002: weather (EXT-002, Open-Meteo) is reached only through WeatherProvider.
    // "open-meteo" calls the service (EXT-002 binding: live in development, free API, no key);
    // "fake" returns synthetic data and never leaves the machine (always in tests).
    'provider' => env('WEATHER_PROVIDER', env('APP_ENV') === 'testing' ? 'fake' : 'open-meteo'),

    // Open-Meteo endpoints (OPS-002: from the environment). Forecast and elevation live under
    // OPEN_METEO_BASE_URL, the historical archive under its own host. Every call is limited to
    // `timeout` seconds; daily values are aggregated in `timezone`.
    'open_meteo' => [
        'base_url' => env('OPEN_METEO_BASE_URL', 'https://api.open-meteo.com'),
        'archive_url' => env('OPEN_METEO_ARCHIVE_URL', 'https://archive-api.open-meteo.com'),
        'timeout' => 10,
        'timezone' => 'Europe/Athens',
    ],

    // Weather cells: a grid of `grid_step` degrees (0.1° is about 11 km north-south and
    // 9 km east-west in Greece). One forecast and one set of climate metrics per cell.
    'grid_step' => 0.1,

    // DATA-009: cell climate metrics come from the last `history_years` full calendar years.
    'history_years' => 10,

    // INT-002 failure policy: retried 3 times through the queue with these delays (seconds).
    'retry_backoff' => [30, 120, 600],

];
