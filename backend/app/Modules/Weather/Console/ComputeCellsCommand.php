<?php

namespace App\Modules\Weather\Console;

use App\Modules\Weather\Jobs\ComputeCellClimate;
use App\Modules\Weather\Models\WeatherCell;
use Illuminate\Console\Command;

/**
 * Queues a new climate-metrics run for every weather cell that still has none, e.g. after the
 * weather service was unavailable for longer than the retries (INT-002).
 */
class ComputeCellsCommand extends Command
{
    protected $signature = 'weather:compute-cells';

    protected $description = 'Queue climate metrics for weather cells that have none yet';

    public function handle(): int
    {
        $count = 0;

        WeatherCell::query()
            ->where(fn ($query) => $query->whereNull('elevation_m')->orWhereNull('winter_min_mean_c'))
            ->select('id')
            ->lazyById()
            ->each(function (WeatherCell $cell) use (&$count): void {
                ComputeCellClimate::dispatch($cell->id);
                $count++;
            });

        $this->info("Queued {$count} weather cell(s).");

        return self::SUCCESS;
    }
}
