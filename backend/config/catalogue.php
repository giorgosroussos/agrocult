<?php

return [

    // Catalogue photos uploaded in the admin panel (ENT-PlantPhoto). Stored through the
    // Laravel filesystem (OPS-002); the default "local" disk is private.
    'photos' => [
        'disk' => env('CATALOGUE_PHOTO_DISK', 'local'),
        'directory' => 'catalogue/photos',

        // SEC-003: only JPEG, PNG or WebP up to 5 MB.
        'max_kilobytes' => 5120,
        'mime_types' => ['image/jpeg', 'image/png', 'image/webp'],
    ],

    // EXT-006 / INT-006: open plant data sources used by `php artisan catalogue:import-plant`.
    // Endpoints and credentials come from the environment (OPS-002); every call is
    // limited to `timeout` seconds and a failure is retried by re-running the command.
    // Only sources whose licence allows commercial use (SCOPE-001, DEC-006).
    'import' => [
        'timeout' => 30,
        'user_agent' => env('CATALOGUE_IMPORT_USER_AGENT', 'AgrocultCatalogueImport/1.0'),

        'sources' => [
            'gbif' => [
                'name' => 'GBIF Backbone Taxonomy',
                'url' => env('GBIF_API_URL', 'https://api.gbif.org/v1'),
                'licence' => 'CC BY 4.0',
            ],
            'wikidata' => [
                'name' => 'Wikidata',
                'url' => env('WIKIDATA_SPARQL_URL', 'https://query.wikidata.org/sparql'),
                'licence' => 'CC0 1.0',
            ],
            'openfarm' => [
                'name' => 'OpenFarm (crops rescue)',
                'url' => env('OPENFARM_CROPS_URL', 'https://raw.githubusercontent.com/thefullnacho/openfarm-crops-rescue/master/crops.json'),
                'licence' => 'CC0 1.0',
            ],
            'trefle' => [
                'name' => 'Trefle',
                'url' => env('TREFLE_API_URL', 'https://trefle.io'),
                'token' => env('TREFLE_TOKEN'),
                'licence' => env('TREFLE_LICENCE', 'Trefle terms of use (credit Trefle and the original sources)'),
            ],
        ],
    ],

];
