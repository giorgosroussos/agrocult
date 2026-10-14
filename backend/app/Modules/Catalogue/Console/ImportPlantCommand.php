<?php

namespace App\Modules\Catalogue\Console;

use App\Modules\Catalogue\Exceptions\PlantImportRejected;
use App\Modules\Catalogue\Exceptions\PlantSourceUnavailable;
use App\Modules\Catalogue\Import\DraftPlantWriter;
use App\Modules\Catalogue\Import\PlantSource;
use App\Modules\Catalogue\Import\PlantSourceImporter;
use Illuminate\Console\Command;

/**
 * UC-010 / INT-006: imports facts about one plant from the open plant data sources (EXT-006)
 * into a draft plant with FactSource rows. All sources are asked first; if one is unavailable
 * the import stops with a message and nothing is written (a manual re-run is the retry).
 */
class ImportPlantCommand extends Command
{
    protected $signature = 'catalogue:import-plant
        {scientific_name : Scientific name, e.g. "Solanum lycopersicum"}
        {--source=* : gbif, wikidata, openfarm or trefle (default: every configured source)}
        {--category= : Category code, needed when the plant is not in the catalogue yet}';

    protected $description = 'Import facts about a plant from GBIF, Wikidata, OpenFarm and Trefle as a draft plant';

    public function handle(PlantSourceImporter $importer, DraftPlantWriter $writer): int
    {
        $name = (string) preg_replace('/\s+/u', ' ', trim((string) $this->argument('scientific_name')));

        if (preg_match("/^\\p{L}[\\p{L}\\p{M} .×'-]{1,254}$/u", $name) !== 1) {
            $this->error('Give a scientific name of letters, spaces, dots, hyphens or ×, e.g. "Solanum lycopersicum".');

            return self::FAILURE;
        }

        $sources = $this->sources();
        if ($sources === null) {
            return self::FAILURE;
        }

        $category = $this->option('category');
        $category = is_string($category) ? $category : null;

        try {
            $writer->assertWritable($name, $category);
        } catch (PlantImportRejected $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $drafts = [];
        foreach ($sources as $source) {
            $this->line("Asking {$source->displayName()} ...");

            try {
                $draft = $importer->import($source, $name);
            } catch (PlantSourceUnavailable $e) {
                $this->error($e->getMessage());
                $this->error('The import stopped; nothing was written or published. Run the command again later.');

                return self::FAILURE;
            }

            $this->line('  '.count($draft->facts).' facts');
            if (! $draft->isEmpty()) {
                $drafts[] = $draft;
            }
        }

        if ($drafts === []) {
            $this->warn("No source has facts about {$name}; nothing was written.");

            return self::SUCCESS;
        }

        try {
            $result = $writer->write($name, $drafts, $category);
        } catch (PlantImportRejected $e) {
            $this->error($e->getMessage());

            return self::FAILURE;
        }

        $this->info(($result->created ? 'Created draft plant ' : 'Updated draft plant ').$result->plant->scientific_name.'.');
        $this->printList('Written', $result->applied);
        $this->printList('Confirmed', $result->confirmed);
        $this->printList('Not written (cross-check in the admin panel)', $result->skipped);
        $this->info('The plant stays a draft: review and publish it in the admin panel.');

        return self::SUCCESS;
    }

    /**
     * @return list<PlantSource>|null null after an error message
     */
    private function sources(): ?array
    {
        $requested = (array) $this->option('source');

        if ($requested === []) {
            return PlantSource::configured();
        }

        $sources = [];
        foreach ($requested as $value) {
            $source = PlantSource::tryFrom(strtolower((string) $value));

            if ($source === null) {
                $this->error("Unknown source {$value}; use gbif, wikidata, openfarm or trefle.");

                return null;
            }

            if (! $source->isConfigured()) {
                $this->error("{$source->displayName()} is not configured (see config/catalogue.php; Trefle needs TREFLE_TOKEN).");

                return null;
            }

            $sources[$source->value] = $source;
        }

        return array_values($sources);
    }

    /**
     * @param  list<string>  $lines
     */
    private function printList(string $heading, array $lines): void
    {
        if ($lines === []) {
            return;
        }

        $this->line("{$heading}:");
        foreach ($lines as $line) {
            $this->line("  - {$line}");
        }
    }
}
