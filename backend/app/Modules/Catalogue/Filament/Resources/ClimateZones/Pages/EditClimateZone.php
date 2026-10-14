<?php

namespace App\Modules\Catalogue\Filament\Resources\ClimateZones\Pages;

use App\Modules\Catalogue\Filament\Resources\ClimateZones\ClimateZoneResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditClimateZone extends EditRecord
{
    protected static string $resource = ClimateZoneResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
