<?php

namespace App\Modules\Weather\Jobs;

use App\Modules\Weather\Climate\CellZones;
use App\Modules\Weather\Climate\ClimateMetrics;
use App\Modules\Weather\Exceptions\WeatherUnavailable;
use App\Modules\Weather\Models\WeatherCell;
use App\Modules\Weather\Provider\WeatherProvider;
use Carbon\CarbonImmutable;
use Illuminate\Contracts\Queue\ShouldBeUnique;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Computes the climate metrics of one weather cell once (DATA-001, DATA-009): its elevation and
 * one history call for the last 10 full calendar years, then the nearest climate zone.
 *
 * INT-002 failure policy: a failed or timed-out call is retried 3 times through the queue
 * (30 s, 2 m, 10 m). Metrics and zone are stored together only after both calls succeeded, so
 * after the last retry the cell keeps no metrics and no zone until a later run succeeds.
 */
class ComputeCellClimate implements ShouldBeUnique, ShouldQueue
{
    use Queueable;

    /** The first attempt plus 3 retries. */
    public int $tries = 4;

    /** Releases the unique lock if a run is lost (longer than all retries together). */
    public int $uniqueFor = 3600;

    public function __construct(public readonly string $weatherCellId) {}

    public function uniqueId(): string
    {
        return $this->weatherCellId;
    }

    /**
     * @return list<int> seconds before each retry
     */
    public function backoff(): array
    {
        /** @var list<int> $backoff */
        $backoff = array_map('intval', (array) config('weather.retry_backoff', [30, 120, 600]));

        return $backoff;
    }

    public function handle(WeatherProvider $weather, CellZones $zones): void
    {
        $cell = WeatherCell::query()->find($this->weatherCellId);

        if ($cell === null || $cell->hasMetrics()) {
            return;
        }

        $years = max(1, (int) config('weather.history_years', 10));
        $lastYear = CarbonImmutable::now()->year - 1;
        $from = CarbonImmutable::create($lastYear - $years + 1, 1, 1);
        $to = CarbonImmutable::create($lastYear, 12, 31);

        if ($from === null || $to === null) {
            return;
        }

        $elevation = $weather->elevation($cell->lat, $cell->lon);
        $metrics = ClimateMetrics::fromHistory($elevation, $weather->history($cell->lat, $cell->lon, $from, $to));

        if ($metrics === null) {
            throw WeatherUnavailable::because('history', 'no daily minimum temperatures');
        }

        $zones->storeMetrics($cell, $metrics);
    }

    public function failed(?Throwable $exception): void
    {
        // SEC-002: only the cell id, never its coordinates.
        Log::warning('Weather cell climate metrics unavailable; the cell stays without metrics and zone.', [
            'weather_cell_id' => $this->weatherCellId,
            'reason' => $exception instanceof WeatherUnavailable ? $exception->getMessage() : ($exception === null ? null : $exception::class),
        ]);
    }
}
