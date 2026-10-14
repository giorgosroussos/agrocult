<?php

namespace App\Modules\Catalogue\Import;

/**
 * One imported fact about a plant. Facts only: source texts are never copied (EXT-006).
 *
 * The field is one of:
 *  - a structured ENT-Plant attribute (see DraftPlantWriter::ATTRIBUTES), e.g. "gbif_id";
 *  - "name.<lang>": the plant name in a language (ENT-PlantTranslation.name);
 *  - "alias.<lang>": another name in a language (ENT-PlantAlias);
 *  - "companion": the scientific name of a good neighbour (ENT-Companion).
 */
final readonly class Fact
{
    public function __construct(
        public string $field,
        public int|float|string $value,
    ) {}
}
