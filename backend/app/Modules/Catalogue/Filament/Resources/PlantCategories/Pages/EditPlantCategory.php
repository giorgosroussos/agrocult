<?php

namespace App\Modules\Catalogue\Filament\Resources\PlantCategories\Pages;

use App\Modules\Catalogue\Filament\Resources\PlantCategories\PlantCategoryResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditPlantCategory extends EditRecord
{
    protected static string $resource = PlantCategoryResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
