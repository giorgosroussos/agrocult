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

];
