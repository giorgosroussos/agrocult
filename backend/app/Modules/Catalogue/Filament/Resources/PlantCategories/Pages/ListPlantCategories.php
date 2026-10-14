<?php

namespace App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages;

use App\Modules\Catalogue\Filament\Resources\PlantCategories\PlantCategoryResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListPlantCategories extends ListRecords
{
    protected static string $resource = PlantCategoryResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
