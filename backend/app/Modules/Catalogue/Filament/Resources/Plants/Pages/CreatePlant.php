<?php

namespace App\Modules\Catalogue\Filament\Resources\Plants\Pages;

use App\Modules\Catalogue\Filament\Resources\Plants\PlantResource;
use Filament\Resources\Pages\CreateRecord;

/**
 * New plants always start as draft (ENT-Plant state model).
 */
class CreatePlant extends CreateRecord
{
    protected static string $resource = PlantResource::class;
}
