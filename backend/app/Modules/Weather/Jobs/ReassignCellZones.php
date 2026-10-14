<?php

namespace App\Modules\Weather\Jobs;

use App\Modules\Weather\Climate\CellZones;
use Illuminate\Contracts\Queue\ShouldBeUniqueUntilProcessing;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/**
 * Re-assigns the climate zone of every cell with metrics after zone rules changed (DATA-009)
 * and emits CellZoneChanged for each cell whose zone changed.
 *
 * Unique until processing: several rule edits saved together queue one run, and an edit made
 * while a run is in progress queues the next one.
 */
class ReassignCellZones implements ShouldBeUniqueUntilProcessing, ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public int $backoff = 30;

    public function handle(CellZones $zones): void
    {
        $zones->reassignAll();
    }
}
