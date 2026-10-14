<?php

namespace App\Modules\Catalogue\Import;

use Carbon\CarbonImmutable;

/**
 * What one source knows about one plant (INT-006 `import(source, scientific_name) -> DraftFacts`),
 * with the source and licence recorded for every fact (SCOPE-001).
 */
final readonly class DraftFacts
{
    /**
     * @param  list<Fact>  $facts
     */
    public function __construct(
        public PlantSource $source,
        public string $scientificName,
        public array $facts,
        public string $licence,
        public ?string $sourceUrl,
        public CarbonImmutable $importedAt,
    ) {}

    public static function none(PlantSource $source, string $scientificName): self
    {
        return new self($source, $scientificName, [], $source->licence(), null, CarbonImmutable::now('UTC'));
    }

    public function isEmpty(): bool
    {
        return $this->facts === [];
    }
}
