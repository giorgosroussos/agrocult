<?php

namespace App\Modules\Weather\Services;

use App\Modules\Weather\Jobs\ComputeCellClimate;
use App\Modules\Weather\Models\WeatherCell;
use Illuminate\Support\Facades\DB;

/**
 * Public service of CMP-Weather for other modules (CMP-Gardens): the weather cell of a
 * location and the cell's climate zone (DATA-001: a garden's zone always comes from its cell).
 */
class WeatherCells
{
    /**
     * The id of the cell that contains the location, creating the cell when needed. A cell
     * without metrics gets its climate metrics computed in a queued job (DATA-009); until that
     * succeeds it has no zone.
     */
    public function cellFor(float $lat, float $lon): string
    {
        [$lat, $lon] = $this->snap($lat, $lon);

        $cell = WeatherCell::query()->createOrFirst(['lat' => $lat, 'lon' => $lon]);

        if (! $cell->hasMetrics()) {
            $id = $cell->id;
            // After the commit: the unique lock of the job must not run inside an open transaction.
            DB::afterCommit(fn () => ComputeCellClimate::dispatch($id));
        }

        return $cell->id;
    }

    /**
     * The climate zone of a cell; null while the cell has no metrics (SCOPE-004).
     */
    public function climateZoneId(string $weatherCellId): ?string
    {
        $zone = WeatherCell::query()->whereKey($weatherCellId)->value('climate_zone_id');

        return is_string($zone) ? $zone : null;
    }

    /**
     * Centre of the grid cell that contains the location.
     *
     * @return array{0: float, 1: float}
     */
    public function snap(float $lat, float $lon): array
    {
        $step = (float) config('weather.grid_step', 0.1);

        return [round(round($lat / $step) * $step, 4), round(round($lon / $step) * $step, 4)];
    }
}
