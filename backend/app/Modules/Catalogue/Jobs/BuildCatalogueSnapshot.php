<?php

namespace App\Modules\Catalogue\Jobs;

use App\Modules\Catalogue\Services\CatalogueSnapshots;
use Illuminate\Contracts\Queue\ShouldBeUniqueUntilProcessing;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

/**
 * Rebuilds the catalogue snapshot after a publish or a change to published content (ARCH-003).
 *
 * Unique until processing: many changes saved together (e.g. one edit form) queue one build,
 * and a change made while a build runs queues the next one. A failed build leaves the
 * previous snapshot in place.
 */
class BuildCatalogueSnapshot implements ShouldBeUniqueUntilProcessing, ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public int $backoff = 30;

    public function handle(CatalogueSnapshots $snapshots): void
    {
        $snapshots->rebuild();
    }
}
