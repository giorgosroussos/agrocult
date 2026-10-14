<?php

namespace App\Modules\Catalogue\Console;

use App\Modules\Catalogue\Services\CatalogueSnapshots;
use Illuminate\Console\Command;

/**
 * Builds the catalogue snapshot now (normally a queued job does this after every publish).
 * With --output the current snapshot is also copied to a file, e.g. the snapshot bundled
 * in the app (ARCH-003).
 */
class BuildSnapshotCommand extends Command
{
    protected $signature = 'catalogue:build-snapshot
        {--output= : Also copy the current snapshot to this file}';

    protected $description = 'Build the catalogue snapshot for devices from the published catalogue';

    public function handle(CatalogueSnapshots $snapshots): int
    {
        $info = $snapshots->rebuild();

        $this->info(sprintf('Catalogue snapshot v%d (%d bytes, sha256 %s).', $info->version, $info->size, $info->sha256));

        $output = $this->option('output');

        if (is_string($output) && $output !== '') {
            $stream = $snapshots->disk()->readStream($info->path);
            $target = @fopen($output, 'wb');

            if (! is_resource($stream) || $target === false) {
                $this->error('Could not copy the snapshot to '.$output.'.');

                return self::FAILURE;
            }

            stream_copy_to_stream($stream, $target);
            fclose($target);
            fclose($stream);

            $this->info('Copied to '.$output.'.');
        }

        return self::SUCCESS;
    }
}
