<?php

namespace App\Modules\Catalogue\Exceptions;

use DomainException;

/**
 * A plant cannot be published while a required structured field is missing (UC-010).
 */
class PlantNotPublishable extends DomainException
{
    /**
     * @param  list<string>  $missingFields
     */
    public function __construct(public readonly array $missingFields)
    {
        parent::__construct('A plant cannot be published without: '.implode(', ', $missingFields).'.');
    }
}
