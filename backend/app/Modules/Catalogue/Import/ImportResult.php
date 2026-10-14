<?php

namespace App\Modules\Catalogue\Import;

use App\Modules\Catalogue\Models\Plant;

/**
 * Outcome of writing imported facts to a draft plant, for the curator to cross-check.
 */
final readonly class ImportResult
{
    /**
     * @param  list<string>  $applied  facts written to the plant
     * @param  list<string>  $confirmed  facts that agree with what the plant already has
     * @param  list<string>  $skipped  facts not written, with the reason (conflicts, unknown companions)
     */
    public function __construct(
        public Plant $plant,
        public bool $created,
        public array $applied,
        public array $confirmed,
        public array $skipped,
    ) {}
}
