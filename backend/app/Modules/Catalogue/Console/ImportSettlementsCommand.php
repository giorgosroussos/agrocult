<?php

namespace App\Modules\Catalogue\Console;

use App\Modules\Catalogue\Import\SettlementImporter;
use Illuminate\Console\Command;
use InvalidArgumentException;

/**
 * Replaces the settlement list (ENT-Settlement) from an OpenStreetMap export. The export is
 * downloaded by the owner (e.g. with the Overpass query below), so the command itself calls
 * no external system.
 */
class ImportSettlementsCommand extends Command
{
    protected $signature = 'catalogue:import-settlements
        {file : Overpass API JSON export of Greek settlements}';

    protected $description = 'Replace the settlement list from an OpenStreetMap (Overpass JSON) export';

    protected $help = <<<'HELP'
        Export the settlements of Greece from OpenStreetMap with an Overpass query such as:

          [out:json][timeout:180];
          area["ISO3166-1"="GR"][admin_level=2]->.gr;
          nwr["place"~"^(city|town|village|hamlet)$"](area.gr);
          out center tags;

        The Greek name is name:el (or name), the English name name:en and the region
        is_in:region, is_in:state, addr:region or addr:state. OpenStreetMap data is
        (c) OpenStreetMap contributors, ODbL.
        HELP;

    public function handle(SettlementImporter $importer): int
    {
        $file = (string) $this->argument('file');

        if (! is_file($file) || ! is_readable($file)) {
            $this->error("Cannot read {$file}; the settlement list is unchanged.");

            return self::FAILURE;
        }

        try {
            $settlements = $importer->parse((string) file_get_contents($file));
        } catch (InvalidArgumentException $e) {
            $this->error($e->getMessage().' The settlement list is unchanged.');

            return self::FAILURE;
        }

        if ($settlements === []) {
            $this->error('The file has no settlement with a name and coordinates; the settlement list is unchanged.');

            return self::FAILURE;
        }

        $count = $importer->replace($settlements);
        $this->info("Imported {$count} settlements.");

        return self::SUCCESS;
    }
}
