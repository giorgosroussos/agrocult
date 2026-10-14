<?php

namespace App\Modules\Weather\Climate;

use App\Modules\Catalogue\Services\ClimateZones;
use App\Modules\Weather\Events\CellZoneChanged;
use App\Modules\Weather\Models\WeatherCell;

/**
 * Gives cells with metrics their nearest climate zone (DATA-009). Zones are read only through
 * the CMP-Catalogue ClimateZones service. CellZoneChanged is emitted only when a cell's zone
 * actually changes.
 */
class CellZones
{
    public function __construct(
        private readonly ClimateZones $zones,
        private readonly ZoneMatcher $matcher,
    ) {}

    /**
     * Stores the metrics of a cell and assigns its zone.
     */
    public function storeMetrics(WeatherCell $cell, ClimateMetrics $metrics): void
    {
        $cell->fill($metrics->toArray());

        $this->assign($cell, $this->zones->all());
    }

    /**
     * Re-assigns every cell that has metrics, e.g. after zone rules changed.
     *
     * @return int number of cells whose zone changed
     */
    public function reassignAll(): int
    {
        $zones = $this->zones->all();
        $changed = 0;

        foreach (WeatherCell::query()->withMetrics()->lazyById() as $cell) {
            if ($this->assign($cell, $zones)) {
                $changed++;
            }
        }

        return $changed;
    }

    /**
     * @param  list<array{id: string, code: string, rules: array<string, mixed>}>  $zones
     */
    private function assign(WeatherCell $cell, array $zones): bool
    {
        $metrics = $cell->metrics();
        $previous = $cell->getOriginal('climate_zone_id');
        $previous = is_string($previous) ? $previous : null;
        $zone = $metrics === null ? null : $this->matcher->nearest($metrics, $zones);

        $cell->climate_zone_id = $zone;
        $cell->save();

        if ($previous === $zone) {
            return false;
        }

        CellZoneChanged::dispatch($cell->id, $previous, $zone);

        return true;
    }
}
