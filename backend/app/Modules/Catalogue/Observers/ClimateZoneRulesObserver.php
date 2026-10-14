<?php

namespace App\Modules\Catalogue\Observers;

use App\Modules\Catalogue\Events\ClimateZoneRulesChanged;
use App\Modules\Catalogue\Models\ClimateZone;
use Illuminate\Support\Facades\DB;

/**
 * Emits ClimateZoneRulesChanged (after the commit) when the set of zone rules changes: a zone
 * is created, its rules are edited, or it is deleted (DATA-009).
 */
class ClimateZoneRulesObserver
{
    public function created(ClimateZone $zone): void
    {
        $this->emit($zone);
    }

    public function updated(ClimateZone $zone): void
    {
        if ($zone->wasChanged('rules')) {
            $this->emit($zone);
        }
    }

    public function deleted(ClimateZone $zone): void
    {
        $this->emit($zone);
    }

    private function emit(ClimateZone $zone): void
    {
        $id = (string) $zone->id;

        DB::afterCommit(fn () => ClimateZoneRulesChanged::dispatch($id));
    }
}
