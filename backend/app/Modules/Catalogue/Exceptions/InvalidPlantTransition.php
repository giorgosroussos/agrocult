<?php

namespace App\Modules\Catalogue\Exceptions;

use App\Modules\Catalogue\Enums\PlantStatus;
use DomainException;

/**
 * A plant status change that is not in the ENT-Plant state model.
 */
class InvalidPlantTransition extends DomainException
{
    public function __construct(
        public readonly ?PlantStatus $from,
        public readonly PlantStatus $to,
    ) {
        parent::__construct($from === null
            ? "A new plant must start as '".PlantStatus::INITIAL->value."', not '{$to->value}'."
            : "A plant cannot change from '{$from->value}' to '{$to->value}'.");
    }
}
