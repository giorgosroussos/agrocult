<?php

namespace App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages;

use App\Modules\Catalogue\Filament\Resources\PlantCategories\PlantCategoryResource;
use Filament\Resources\Pages\CreateRecord;

class CreatePlantCategory extends CreateRecord
{
    protected static string $resource = PlantCategoryResource::class;
}
