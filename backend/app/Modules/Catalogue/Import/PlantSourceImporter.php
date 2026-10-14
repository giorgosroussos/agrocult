<?php

namespace App\Modules\Catalogue\Import;

use App\Modules\Catalogue\Exceptions\PlantSourceUnavailable;

/**
 * INT-006: the only way to reach the open plant data sources (EXT-006).
 */
interface PlantSourceImporter
{
    /**
     * Facts the source has about the plant; empty when the source does not know it.
     *
     * @throws PlantSourceUnavailable when the source is not configured, times out,
     *                                cannot be reached or answers with an error
     */
    public function import(PlantSource $source, string $scientificName): DraftFacts;
}
