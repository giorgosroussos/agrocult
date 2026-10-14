<?php

namespace App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages;

use App\Modules\Catalogue\Filament\Resources\ClimateZones\ClimateZoneResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListClimateZones extends ListRecords
{
    protected static string $resource = ClimateZoneResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
