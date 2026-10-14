<?php

namespace App\Modules\Catalogue\Policies;

use App\Modules\Catalogue\Models\ClimateZone;
use App\Modules\Catalogue\Models\Tip;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Database\Eloquent\Model;

/**
 * A climate zone is deleted only while no calendar row and no tip refers to it.
 */
class ClimateZonePolicy extends CataloguePolicy
{
    public function delete(Authenticatable $user, Model $record): bool
    {
        return $this->curates($user)
            && $record instanceof ClimateZone
            && ! $record->calendars()->exists()
            && ! Tip::query()->where('climate_zone_id', $record->id)->exists();
    }
}
