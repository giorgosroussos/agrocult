<?php

namespace App\Modules\Catalogue;

use App\Modules\Catalogue\Console\BuildSnapshotCommand;
use App\Modules\Catalogue\Console\ImportPlantCommand;
use App\Modules\Catalogue\Console\ImportSettlementsCommand;
use App\Modules\Catalogue\Import\HttpPlantSourceImporter;
use App\Modules\Catalogue\Import\PlantSourceImporter;
use App\Modules\Catalogue\Models\CareInterval;
use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Companion;
use App\Modules\Catalogue\Models\FactSource;
use App\Modules\Catalogue\Models\Plant;
use App\Modules\Catalogue\Models\PlantAlias;
use App\Modules\Catalogue\Models\PlantCalendar;
use App\Modules\Catalogue\Models\PlantCategory;
use App\Modules\Catalogue\Models\PlantPhoto;
use App\Modules\Catalogue\Models\PlantTranslation;
use App\Modules\Catalogue\Models\Settlement;
use App\Modules\Catalogue\Models\Tip;
use App\Modules\Catalogue\Observers\CatalogueSnapshotTrigger;
use App\Modules\Catalogue\Policies\CataloguePolicy;
use App\Modules\Catalogue\Policies\ClimateZonePolicy;
use App\Modules\Catalogue\Policies\PlantCategoryPolicy;
use App\Modules\Catalogue\Services\CataloguePhotoStore;
use App\Support\Modules\ModuleServiceProvider;
use Illuminate\Support\Facades\Gate;

/**
 * CMP-Catalogue: plants and their texts, aliases, calendars, companions, care intervals,
 * photos, sources, tips, climate zones and settlements; curation in the admin panel.
 */
class CatalogueServiceProvider extends ModuleServiceProvider
{
    public function register(): void
    {
        $this->app->scoped(CataloguePhotoStore::class);

        // INT-006: the open plant data sources (EXT-006) are reached only through this interface.
        $this->app->bind(PlantSourceImporter::class, HttpPlantSourceImporter::class);
    }

    public function boot(): void
    {
        parent::boot();

        $this->loadTranslationsFrom($this->modulePath().'/resources/lang', 'catalogue');

        if ($this->app->runningInConsole()) {
            $this->commands([ImportPlantCommand::class, ImportSettlementsCommand::class, BuildSnapshotCommand::class]);
        }

        // UC-010: only accounts that may use the admin panel curate the catalogue.
        foreach ([Plant::class, PlantTranslation::class, PlantAlias::class, PlantCalendar::class, Companion::class,
            CareInterval::class, PlantPhoto::class, FactSource::class, Tip::class] as $model) {
            Gate::policy($model, CataloguePolicy::class);
        }

        Gate::policy(PlantCategory::class, PlantCategoryPolicy::class);
        Gate::policy(ClimateZone::class, ClimateZonePolicy::class);

        // ARCH-003: publishing (and editing published content) rebuilds the device snapshot.
        foreach ([Plant::class, PlantTranslation::class, PlantAlias::class, PlantCalendar::class, Companion::class,
            CareInterval::class, PlantPhoto::class, FactSource::class, Tip::class, PlantCategory::class,
            ClimateZone::class, Settlement::class] as $model) {
            $model::observe(CatalogueSnapshotTrigger::class);
        }
    }
}
