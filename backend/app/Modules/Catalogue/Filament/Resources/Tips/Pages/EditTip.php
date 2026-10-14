<?php

namespace App\Modules\Catalogue\Filament\Resources\Tips\Pages;

use App\Modules\Catalogue\Filament\Resources\Tips\TipResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditTip extends EditRecord
{
    protected static string $resource = TipResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
