<?php

use App\Modules\Catalogue\CatalogueServiceProvider;
use App\Modules\Gardens\GardensServiceProvider;
use App\Modules\Identification\IdentificationServiceProvider;
use App\Modules\Identity\Filament\AdminPanelProvider;
use App\Modules\Identity\IdentityServiceProvider;
use App\Modules\Notifications\NotificationsServiceProvider;
use App\Modules\Privacy\PrivacyServiceProvider;
use App\Modules\Weather\WeatherServiceProvider;
use App\Providers\AppServiceProvider;

return [
    AppServiceProvider::class,
    IdentityServiceProvider::class,
    CatalogueServiceProvider::class,
    WeatherServiceProvider::class,
    GardensServiceProvider::class,
    IdentificationServiceProvider::class,
    NotificationsServiceProvider::class,
    PrivacyServiceProvider::class,
    AdminPanelProvider::class,
];
