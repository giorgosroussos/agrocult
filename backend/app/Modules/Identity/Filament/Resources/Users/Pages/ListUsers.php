<?php

namespace App\Modules\Identity\Filament\Resources\Users\Pages;

use App\Modules\Identity\Filament\Resources\Users\UserResource;
use Filament\Resources\Pages\ListRecords;

class ListUsers extends ListRecords
{
    protected static string $resource = UserResource::class;
}
