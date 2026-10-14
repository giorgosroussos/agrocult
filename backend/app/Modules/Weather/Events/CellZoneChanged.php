<?php

namespace App\Modules\Weather\Events;

use Illuminate\Foundation\Events\Dispatchable;

/**
 * The climate zone of a weather cell changed (DATA-009): the cell got its first zone after its
 * metrics were computed, or zone rules changed and the cell now has a different zone.
 * CMP-Gardens gives the gardens of the cell the new zone.
 */
class CellZoneChanged
{
    use Dispatchable;

    public function __construct(
        public readonly string $weatherCellId,
        public readonly ?string $previousClimateZoneId,
        public readonly ?string $climateZoneId,
    ) {}
}
