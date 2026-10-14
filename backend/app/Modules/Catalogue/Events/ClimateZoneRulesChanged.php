<?php

namespace App\Modules\Catalogue\Events;

use Illuminate\Foundation\Events\Dispatchable;

/**
 * A curator created a climate zone, changed its rules or deleted it (DATA-009). Emitted after
 * the change is committed; CMP-Weather re-assigns the zones of all weather cells.
 */
class ClimateZoneRulesChanged
{
    use Dispatchable;

    public function __construct(public readonly string $climateZoneId) {}
}
